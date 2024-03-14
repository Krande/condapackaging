# Failure Identification

```bash
create_suite("temp/py311fail_float", ["mtlp100a|ttnp200a|mtlp102a|ttna200a"])
create_suite("temp/py311fail_no_ok", ["zzzz395q|zzzz395e|supv004a|sdll123f"])
create_suite("temp/py311fail_float_as_int", ["ssls141b|ssls141d|ahlv302g"])
create_suite("temp/py311fail_libumat", ["zzzz409a"])
create_suite("temp/py311fail_get_mat_names", ["zzzz503h"])
create_suite("temp/py311fail_sing_matr", ["wtnv113k"])
create_suite("temp/py311fail_JeveuxCollection", ["zzzz381a|cont001a|ssll111b"])
```
# Zacier.F90

In total 4 failures are referring to line 94 in file zacier.F90:

```
mtlp100a|ttnp200a|mtlp102a|ttna200a
```

These will be fixed -> https://gitlab.com/codeaster/src/-/issues/1#note_1535304749 