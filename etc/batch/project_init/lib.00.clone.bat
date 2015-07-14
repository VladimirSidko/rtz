echo Clone %1 into %2

call git clone %1 %2
cd %2
call git config --add remote.origin.push +refs/tags/*:refs/tags/*
call git config --add remote.origin.fetch +refs/tags/*:refs/tags/*
cd %PROJ_ROOT%

