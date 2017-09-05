@ECHO OFF

cmd /c "puppet apply -v --modulepath=C:\puppet\development\modules C:\puppet\development\manifests\site.pp"
