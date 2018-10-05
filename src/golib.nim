# Copyright (c) 2015-2018, Ștefan Talpalaru <stefantalpalaru@yahoo.com>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS

{.deadCodeElim: on.}

import macros, strutils, typetraits

const
    SELECT_DIR_SEND* = 1
    SELECT_DIR_RECV* = 2
    SELECT_DIR_DEFAULT* = 3

type
    ## work around nimbase.h not looking for _Bool when defining NIM_BOOL
    ## this may require --passC:"--std=gnu99" (or c99, or a more recent standard) in the .cfg file
    cbool {.importc: "_Bool", nodecl.} = bool

    goroutine_type* = proc (x: pointer) {.cdecl.}

    chan_select_case* {.importc: "chan_select_case".} = object
        dir*: cuint
        chan*: pointer
        send*: pointer

    chan_select_cases*{.unchecked.} = array[0..0, chan_select_case]

    chan_select_result* {.importc: "chan_select_result".} = object
        chosen*: cint
        recv*: pointer
        recv_ok*: cbool

    chan_recv2_result* {.importc: "chan_recv2_result".} = object
        recv*: pointer
        ok*: cbool

## libgo and golib symbols
proc go_go*(f: goroutine_type; a3: pointer): pointer {.cdecl, importc: "__go_go", header: "<golib/golib.h>", discardable.}
proc runtime_gomaxprocsfunc*(n: int32): int32 {.cdecl, importc: "runtime_gomaxprocsfunc", header: "<golib/golib.h>", discardable.}
proc getproccount*(): int32 {.cdecl, importc: "getproccount", header: "<golib/golib.h>".}
proc go_yield*() {.cdecl, importc: "go_yield", header: "<golib/golib.h>".}
proc golib_main_proc*(argc: cint; argv: cstringArray) {.cdecl, importc: "golib_main", header: "<golib/golib.h>".}
proc chan_make*(a2: cint): pointer {.cdecl, importc: "chan_make", header: "<golib/golib.h>".}
proc chan_send*(a2: pointer; a3: pointer) {.cdecl, importc: "chan_send", header: "<golib/golib.h>".}
proc chan_recv*(a2: pointer): pointer {.cdecl, importc: "chan_recv", header: "<golib/golib.h>".}
proc chan_recv2*(a2: pointer): chan_recv2_result {.cdecl, importc: "chan_recv2", header: "<golib/golib.h>".}
proc chan_close*(a2: pointer) {.cdecl, importc: "chan_close", header: "<golib/golib.h>".}
proc chan_select*(a2: ptr chan_select_case; a3: cint): chan_select_result {.cdecl, importc: "chan_select", header: "<golib/golib.h>".}
proc go_sleep_ms*(a2: int64) {.cdecl, importc: "go_sleep_ms", header: "<golib/golib.h>".}

## macros
{.push hint[GlobalVar]: off.}
var
    gomain_proc {.compileTime.}: string

proc get_proc_args_tuple_ref(prc: NimNode): NimNode {.compileTime.} =
    result = ident(prc.lineinfo.replace('.', '_').replace('(', '_')
        .replace(',', '_').replace(')', '_') & $prc[0] & "_args_tuple_ref_for_goroutine")

proc count_params(prc: NimNode): int {.compileTime.} =
    for i in prc[3].children:
        if i.kind == nnkIdentDefs:
            result += i.len - 2

macro goroutine*(prc: untyped): untyped =
    # echo treeRepr(prc)
    result = prc
    ## checks
    if prc.kind != nnkProcDef:
        error(prc.lineinfo & ": Cannot transform this node kind into a goroutine. Proc definition expected.")
    if prc[3][0].kind != nnkEmpty:
        error(prc.lineinfo & ": Goroutines should not return anything.")
    if prc[3].len > 1:
        ## we have parameters, move them in a tuple definition before the proc definition
        var
            num_params = count_params(prc)
        if num_params == 1:
            ## there's a single param and we can't assign (val) to a tuple without using the form (name: val)
            ## which we can't do in the 'go' macro, so add a second param
            prc[3].add(
                newIdentDefs(
                    ident("bogus_param_for_goroutine"),
                    ident("pointer")
                )
            )
        ## var (arg1, arg2, ...) = cast[ref tuple[arg1: type1, arg2: type2, ...]](args_for_goroutine)[]
        prc[6].insert(0, newNimNode(nnkVarSection).add(
            newNimNode(nnkVarTuple)
        ))
        for i in 1..(len(prc[3]) - 1):
            for j in 0..(prc[3][i].len - 3):
                prc[6][0][0].add(copyNimNode(prc[3][i][j]))
        prc[6][0][0].add(
            newEmptyNode(),
            newNimNode(nnkBracketExpr).add(
                newNimNode(nnkCast).add(
                    newNimNode(nnkRefTy).add(
                        newNimNode(nnkTupleTy)
                    ),
                    ident("args_for_goroutine")
                )
            )
        )
        for i in 1..(len(prc[3]) - 1):
            prc[6][0][0].last()[0][0][0].add(copyNimTree(prc[3][i]))
        ## delete the params from the proc
        del(prc[3], 1, len(prc[3]) - 1)

        if num_params == 1:
            var push_pragma = parseStmt("{.push hint[XDeclaredButNotUsed]: off.}")
            var pop_pragma = parseStmt("{.pop.}")
            result = newStmtList(push_pragma, prc, pop_pragma)

    prc[3].add(
        newIdentDefs(
            ident("args_for_goroutine"),
            ident("pointer")
        )
    )

    ## pragma
    if prc[4].kind == nnkEmpty:
        prc[4] = newNimNode(nnkPragma)
    addIdentIfAbsent(prc[4], "cdecl")
    # echo treeRepr(result)
    # echo repr(result)

macro gomain*(prc: untyped): untyped =
    result = prc
    ## save it in the global var so we can insert it in golib_main
    gomain_proc = $prc[0]
    ## pragma
    if prc[4].kind == nnkEmpty:
        prc[4] = newNimNode(nnkPragma)
    addIdentIfAbsent(prc[4], "cdecl")
    ## set assembler name
    prc[4].add(
        newNimNode(nnkExprColonExpr).add(
            ident("codegenDecl"),
            newStrLitNode("$1 $2$3 __asm__ (\"main.main\");\n$1 $2$3")
        )
    )

macro call_gomain_proc(): untyped = newCall(ident(gomain_proc))

template golib_main*(): untyped =
    {.push hint[GlobalVar]: off.}
    var
        cmdCount {.importc.}: cint
        cmdLine {.importc.}: cstringArray
    golib_main_proc(cmdCount, cmdLine)
    ## avoid the XDeclaredButNotUsed hint and the need for --deadCodeElim:off
    ## (not reached during execution)
    call_gomain_proc()

macro go*(c: untyped): untyped =
    # echo treeRepr(c)
    result = newStmtList()
    if len(c) == 1:
        c.insert(0, ident("go_go"))
        c.add(newNilLit())
        result.add(c)
    else:
        ## we have parameters that need to be moved into a tuple reference,
        ## cast as a pointer and passed to the proc
        var
            proc_args_tuple_ref = get_proc_args_tuple_ref(c)
        ## var procname_args_tuple_ref_for_goroutine: ref type((arg1, arg2, ...))
        result.add(
            newNimNode(nnkVarSection).add(
                newIdentDefs(
                    proc_args_tuple_ref,
                    newNimNode(nnkRefTy).add(
                        newCall(
                            "type",
                            newNimNode(nnkPar)
                        )
                    )
                )
            )
        )
        for i in 1..(len(c) - 1):
            result.last()[0][1][0][1].add(c[i])
        if len(c) == 2:
            ## there's a single param and we can't assign (val) to a tuple without using the form (name: val)
            ## which we can't do in the 'go' macro, so add a second param
            result.last()[0][1][0][1].add(parseStmt("nil.pointer"))
        ## new(procname_args_tuple_ref_for_goroutine)
        result.add(
            newCall(
                ident("new"),
                proc_args_tuple_ref
            )
        )
        ## procname_args_tuple_ref_for_goroutine[] = (arg1, arg2, ...)
        result.add(
            newNimNode(nnkAsgn).add(
                newNimNode(nnkBracketExpr).add(
                    proc_args_tuple_ref
                )
            ).add(
                newNimNode(nnkPar)
            )
        )
        for i in 1..(len(c) - 1):
            result.last()[1].add(c[i])
        if len(c) == 2:
            ## there's a single param and we can't assign (val) to a tuple without using the form (name: val)
            ## which we can't do in the 'go' macro, so add a second param
            result.last()[1].add(newNilLit())
        ## go_go(procname, procname_args_tuple_ref_for_goroutine)
        result.add(
            newCall(
                ident("go_go"),
                c[0],
                proc_args_tuple_ref
            )
        )
    # echo treeRepr(result)
    # echo repr(result)

{.push hint[XDeclaredButNotUsed]: off.}
type
    chan_internal[T] = object
        real_chan: pointer
        capacity: cint
    chan*[T] = ref chan_internal[T]
    send_chan*[T] = distinct chan[T]
    recv_chan*[T] = distinct chan[T]
    chan_recv2_result_typed*[T] = object
        recv*: T
        ok*: bool
{.pop.}

## getters
proc get_chan*[T](c: chan[T]): pointer =
    if c == nil:
        result = nil
    else:
        result = c.real_chan

proc get_chan*[T](c: send_chan[T]): pointer =
    result = chan[T](c).get_chan()

proc get_chan*[T](c: recv_chan[T]): pointer =
    result = cast[chan[T]](c).get_chan()

## converters

converter int_to_cint*(i: int): cint =
    result = cint(i)

converter ref_to_pointer*[T](x: ref T): pointer =
    result = cast[pointer](x)

converter chan_to_send_chan*[T](c: chan[T]): send_chan[T] =
    result = send_chan[T](c)

converter chan_to_recv_chan*[T](c: chan[T]): recv_chan[T] =
    result = recv_chan[T](c)

## debugging helpers

proc `$`*[T](c: chan[T]): string =
    if c == nil:
        result = "chan($#): nil" % T.name
    else:
        result = "chan($#, $#): $#" % [T.name, $(c.capacity), $(cast[uint](c.get_chan))]

proc `$`*[T](c: send_chan[T]): string =
    result = "send_" & $(chan[T](c))

proc `$`*[T](c: recv_chan[T]): string =
    result = "recv_" & $(chan[T](c))

proc `$`*(x: chan_select_case): string =
    var direction: array[1..3, string] = ["SEND", "RECV", "DEFAULT"]
    result = "chan_select_case(dir: $#, chan: $#, send: $#)" % [direction[x.dir], $(cast[uint](x.chan)), $(cast[uint](x.send))]

proc to_string*(x: chan_select_case, T: typedesc): string =
    var
        direction: array[1..3, string] = ["SEND", "RECV", "DEFAULT"]
        send = "nil"
    if x.send != nil:
        send = $((cast[ptr T](x.send))[])
    result = "chan_select_case(dir: $#, chan: $#, send: $#)" % [direction[x.dir], $(cast[uint](x.chan)), send]

## public chan API

proc make_chan*(T: typedesc, n: cint = 0): chan[T] =
    new(result)
    result.real_chan = chan_make(n)
    result.capacity = n

proc send*[T](c: chan[T], m: T) =
    var m_copy: ref T
    new(m_copy)
    deepCopy(m_copy[], m)
    chan_send(c.get_chan, cast[pointer](m_copy))

proc send*[T](c: send_chan[T], m: T) =
    cast[chan[T]](c).send(m)

proc `<-`*[T](c: chan[T], m: T) =
    c.send(m)

proc `<-`*[T](c: send_chan[T], m: T) =
    cast[chan[T]](c) <- m

proc recv*[T](c: chan[T]): ref T {.discardable.} =
    result = cast[ref T](chan_recv(c.get_chan))

proc recv*[T](c: recv_chan[T]): ref T {.discardable.} =
    result = cast[chan[T]](c).recv()

proc `<-`*[T](c: chan[T]): T {.discardable.} =
    result = c.recv()[]

proc `<-`*[T](c: recv_chan[T]): T {.discardable.} =
    result = <- cast[chan[T]](c)

proc recv2*[T](c: chan[T]): chan_recv2_result_typed[T] =
    var
        res: chan_recv2_result = chan_recv2(c.get_chan)
        recv = cast[ref T](res.recv)
    if unlikely(recv == nil):
        reset(result.recv)
    else:
        result.recv = recv[]
    result.ok = res.ok

proc recv2*[T](c: recv_chan[T]): chan_recv2_result_typed[T] =
    result = cast[chan[T]](c).recv2()

proc `<--`*[T](c: chan[T]): (T, bool) =
    var res = c.recv2()
    result = (res.recv, res.ok)

proc `<--`*[T](c: recv_chan[T]): (T, bool) =
    result = <-- cast[chan[T]](c)

proc close*[T](c: chan[T]) =
    chan_close(c.get_chan)

proc close*[T](c: send_chan[T]) =
    cast[chan[T]](c).close()

iterator items*[T](c: chan[T]): T =
    var m: T
    var ok = true
    while ok:
        (m, ok) = <--c
        if ok:
            yield m

iterator items*[T](c: recv_chan[T]): T =
    for m in cast[chan[T]](c):
        yield m

macro select*(s: untyped): untyped =
    # echo treeRepr(s)
    result = newStmtList()
    var rw_scases, default_scases: int
    for scase in s.children:
        if (scase.kind in {nnkCommand, nnkCall} and $(scase[0]) == "scase") or (scase.kind == nnkInfix and $(scase[1]) == "scase"):
            inc rw_scases
        elif scase.kind == nnkCall and $(scase[0]) == "default":
            inc default_scases
        else:
            error(scase.lineinfo & ": Unsupported scase in select.")
    if rw_scases == 0:
        error(s.lineinfo & ": No send or receive scases.")
    if default_scases > 1:
        error(s.lineinfo & ": More than one 'default' scase.")
    var
        var_prefix = s.lineinfo.replace('.', '_').replace('(', '_').replace(',', '_').replace(')', '_')
        select_cases_var = ident(var_prefix & "select_cases")
        select_result_var = ident(var_prefix & "select_result")
        scase_no = -1
        send_var_statements: seq[NimNode] = @[]
        select_cases: seq[NimNode] = @[]
        case_branches: seq[NimNode] = @[]

    for scase in s.children:
        inc scase_no
        if (scase.kind in {nnkCommand, nnkCall} and $(scase[0]) == "scase") or (scase.kind == nnkInfix and $(scase[1]) == "scase"):
            ## a send_chan would skirt type checking by passing a pointer to the C function selecting it for receiving
            ## let's make sure that everything in an 'scase' statement is compilable, or fail at compile time otherwise
            ## static: doAssert(compiles(...), "message")
            var test_expr = scase[1]
            if scase[1].kind == nnkExprEqExpr:
                # it seems compiles() fails with assignments, so just check the right hand side
                test_expr = scase[1][1]
            result.add(
                newNimNode(nnkStaticStmt).add(
                    newNimNode(nnkStmtList).add(
                        newCall(
                            "doAssert",
                            newCall(
                                "compiles",
                                test_expr
                            ),
                            newStrLitNode("- scase does not compile - $1: '$2'" % [scase.lineinfo, repr(test_expr)])
                        )
                    )
                )
            )
            if scase[1].kind == nnkInfix and $(scase[1][0]) == "<-":
                ## send to channel
                var
                    send_var = ident(var_prefix & "send" & $scase_no)
                    send_var_ref = ident(var_prefix & "send" & $scase_no & "_ref")
                ##  var
                ##      send1 = GetValue()
                ##      send1_ref: ref type(send1)
                send_var_statements.add(
                    newNimNode(nnkVarSection).add(
                        newIdentDefs(
                            send_var,
                            newEmptyNode(),
                            scase[1][2]
                        ),
                        newIdentDefs(
                            send_var_ref,
                            newNimNode(nnkRefTy).add(newCall(ident("type"), send_var))
                        )
                    )
                )
                ## new(send1_ref)
                send_var_statements.add(
                    newCall(ident("new"), send_var_ref)
                )
                ## send1_ref[] = send1
                send_var_statements.add(
                    newNimNode(nnkAsgn).add(
                        newNimNode(nnkBracketExpr).add(send_var_ref),
                        send_var
                    )
                )

                ## chan_select_case(dir: SELECT_DIR_SEND, chan: a.get_chan, send: send1_ref),
                select_cases.add(
                    newNimNode(nnkObjConstr).add(
                        ident("chan_select_case"),
                        newNimNode(nnkExprColonExpr).add(
                            ident("dir"),
                            ident("SELECT_DIR_SEND")
                        ),
                        newNimNode(nnkExprColonExpr).add(
                            ident("chan"),
                            newNimNode(nnkDotExpr).add(
                                scase[1][1],
                                ident("get_chan")
                            )
                        ),
                        newNimNode(nnkExprColonExpr).add(
                            ident("send"),
                            send_var_ref
                        ),
                    )
                )

                ## case branch
                case_branches.add(
                    newNimNode(nnkOfBranch).add(
                        newIntLitNode(scase_no),
                        scase[2]
                    )
                )
            else:
                ## receive from channel
                var
                    channel: NimNode
                    statements: NimNode
                if scase.kind == nnkInfix:
                    channel = scase[2]
                    statements = scase[3]
                elif scase[1].kind == nnkPrefix:
                    channel = scase[1][1]
                    statements = scase[2]
                else:
                    channel = scase[1][1][1]
                    statements = scase[2]
                    if $(scase[1][1][0]) == "<-":
                        ## i2 = cast[ptr type(i2)](res.recv)[]
                        statements.insert(0, newNimNode(nnkAsgn).add(
                            scase[1][0],
                            newNimNode(nnkBracketExpr).add(
                                newNimNode(nnkCast).add(
                                    newNimNode(nnkPtrTy).add(
                                        newCall("type", scase[1][0])
                                    ),
                                    newNimNode(nnkDotExpr).add(
                                        select_result_var,
                                        ident("recv")
                                    )
                                )
                            )
                        ))
                    elif $(scase[1][1][0]) == "<--":
                        ## i3 = cast[ptr type(i3)](res.recv)[]
                        ## ok3 = res.recv_ok
                        statements.insert(0, newNimNode(nnkAsgn).add(
                            scase[1][0][0],
                            newNimNode(nnkBracketExpr).add(
                                newNimNode(nnkCast).add(
                                    newNimNode(nnkPtrTy).add(
                                        newCall("type", scase[1][0][0])
                                    ),
                                    newNimNode(nnkDotExpr).add(
                                        select_result_var,
                                        ident("recv")
                                    )
                                )
                            )
                        ))
                        statements.insert(1, newNimNode(nnkAsgn).add(
                            scase[1][0][1],
                            newNimNode(nnkDotExpr).add(
                                select_result_var,
                                ident("recv_ok")
                            )
                        ))
                ## chan_select_case(dir: SELECT_DIR_RECV, chan: c1.get_chan, send: nil),
                select_cases.add(
                    newNimNode(nnkObjConstr).add(
                        ident("chan_select_case"),
                        newNimNode(nnkExprColonExpr).add(
                            ident("dir"),
                            ident("SELECT_DIR_RECV")
                        ),
                        newNimNode(nnkExprColonExpr).add(
                            ident("chan"),
                            newNimNode(nnkDotExpr).add(
                                channel,
                                ident("get_chan")
                            )
                        ),
                        newNimNode(nnkExprColonExpr).add(
                            ident("send"),
                            newNilLit()
                        ),
                    )
                )

                ## case branch
                case_branches.add(
                    newNimNode(nnkOfBranch).add(
                        newIntLitNode(scase_no),
                        statements
                    )
                )
        elif scase.kind == nnkCall and $(scase[0]) == "default":
            ## chan_select_case(dir: SELECT_DIR_DEFAULT, chan: nil, send: nil),
            select_cases.add(
                newNimNode(nnkObjConstr).add(
                    ident("chan_select_case"),
                    newNimNode(nnkExprColonExpr).add(
                        ident("dir"),
                        ident("SELECT_DIR_DEFAULT")
                    ),
                    newNimNode(nnkExprColonExpr).add(
                        ident("chan"),
                        newNilLit()
                    ),
                    newNimNode(nnkExprColonExpr).add(
                        ident("send"),
                        newNilLit()
                    ),
                )
            )
            ## case branch
            case_branches.add(
                newNimNode(nnkOfBranch).add(
                    newIntLitNode(scase_no),
                    scase[1]
                )
            )

    result.add(send_var_statements)
    ## var
    ##     select_cases = [
    ##         chan_select_case(dir: SELECT_DIR_SEND, chan: a.get_chan, send: send1_ref),
    ##         chan_select_case(dir: SELECT_DIR_SEND, chan: b.get_chan, send: send2_ref),
    ##         chan_select_case(dir: SELECT_DIR_DEFAULT, chan: nil, send: nil),
    ##         ]
    ##     res = chan_select(addr select_cases[0], len(select_cases))
    result.add(newNimNode(nnkVarSection).add(
        newIdentDefs(
            select_cases_var,
            newEmptyNode(),
            newNimNode(nnkBracket).add(select_cases)
        ),
        newIdentDefs(
            select_result_var,
            newEmptyNode(),
            newCall(
                "chan_select",
                newNimNode(nnkCommand).add(
                    ident("addr"),
                    newNimNode(nnkBracketExpr).add(
                        select_cases_var,
                        newIntLitNode(0)
                    )
                ),
                newCall("len", select_cases_var)
            )
        )
    ))
    ## case res.chosen:
    ##     of 0:
    ##         ...
    ##     else:
    ##         discard
    result.add(
        newNimNode(nnkCaseStmt).add(
            newNimNode(nnkDotExpr).add(
                select_result_var,
                ident("chosen")
            )
        ).add(
            case_branches
        ).add(
            newNimNode(nnkElse).add(
                newNimNode(nnkStmtList).add(
                    newNimNode(nnkDiscardStmt).add(
                        newEmptyNode()
                    )
                )
            )
        )
    )

    # echo treeRepr(result)

