AC_INIT([golib-nim], [0.0.1], [stefantalpalaru@yahoo.com], [golib-nim], [https://github.com/stefantalpalaru/golib-nim])
AM_INIT_AUTOMAKE([foreign subdir-objects])
LT_INIT

AC_PROG_CC

AC_ARG_ENABLE([gogc], AS_HELP_STRING([--disable-gogc], [Disable the Go garbage collector]))
AS_IF([test "x$enable_gogc" != "xno"], [
       NIMGC="go"
    ], [
       NIMGC="none"
    ])
AC_SUBST(NIMGC)

AC_ARG_VAR([NIM], [the nim executable])
AS_IF([test "x$NIM" == "x"],
    [
       NIM="nim"
    ])

AC_CONFIG_FILES([
                 nim.cfg
                 ])

AC_OUTPUT([Makefile])

