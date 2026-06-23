call make.bat gettext
copy /Y _build\gettext\*.pot ..\locale\en\LC_MESSAGES\
sphinx-intl update -l en