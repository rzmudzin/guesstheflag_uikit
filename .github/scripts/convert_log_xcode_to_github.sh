# Tries to convert from Xcode's error/warning log format to github action format,
# in an attempt to surface build warnings and errors higher in github actions
# (particularly PR test builds).
#
# clang error format is generally:
#  <filename>:<line>:(error|warning): <text>
# Xcode also allows:
#  (error|warning): <text>
# Swift seems to be:
# <filename>:<line>:<column>:(error|warning): <text>
#
# https://docs.github.com/en/actions/using-workflows/workflow-commands-for-github-actions
# Github workflow command for error/warning/notice is:
# ::(error|warning|notice) file=<filename>,line=<line>,title=<customtitle>::<text>
#
# However, the file and line parameter values do not show up in the
# github UI as far as I can see. So, we add those to the text.

sed -E -e 's/^(error|warning): *(.*)$/::\1::\2/g' \
    -E -e 's/^([^:]*):([0-9]*):([0-9]*:)? ?(error|warning): *(.*)$/::\4 file=\1,line=\2,title=\5::\5 (\1:\2)/g'
