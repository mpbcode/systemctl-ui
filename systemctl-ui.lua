#! /usr/bin/lua5.3


--  Copyright (C) 2018, mpb.mail@gmail.com
--  License   GNU General Public License, version 3.  See LICENSE.TXT.
--  Homepage  https://github.com/mpbcode/systemctl-ui


local  concat  =  table .concat
local  insert  =  table .insert

local  stty_save


function  env_lock  ()    ------------------------------------------  env_lock

  local  mt  =  {}
  function  mt .__newindex  ( t, k, v )
    error ( ' invalid global  ' .. k, 2 )  end
  function  mt .__index  ( t, k )
    error ( ' invalid global  ' .. k, 2 )  end
  setmetatable ( _ENV, mt )  end


function  list_unit_files  ()    ----------------------------  list_unit_files

local  cmd  =  '  systemctl --all list-unit-files  |  sort -b -k 2  '
  local  f    =  io .popen ( cmd )
  local  rv   =  {}

  for  line  in  f : lines()  do  repeat
    if  line == '' then  break  end
    if  line : match '^UNIT FILE'  then  break  end
    if  line : match '^%d+ unit files listed.$'  then  break  end
    insert ( rv, line )
    until 'once'  end

  f : close()
  return  rv  end


function  read_char  ()    ----------------------------------------  read_char

  if  stty_save == nil  then
    local  f  =  io .popen ( 'stty --save' )
    stty_save  =  f : read 'a'
    f : close()  end

  os .execute ( '  stty  -icanon  ' )
  local  c  =  io .read ( 1 )
  os .execute ( '  stty  ' .. stty_save )
  return  c  end


function  state  ( line )    ------------------------------------------  state
  return  line : match ( '(%S+)%s*$' )  end


function  stop_and_disable ( unit )    ---------------------  stop_and_disable

  io .write ( '\nstop and disable  ' .. unit .. '  ?  [y/n]  ' )
  local  c  =  read_char()
  io .write ( '\n' )

  if  c == 'y'  then
    local  command  =  ("systemctl  stop  '%s'") : format ( unit )

    print ( command )
    print ( os .execute ( command ) )

    local  command  =  ("systemctl  disable  '%s'") : format ( unit )

    print ( command )
    print ( os .execute ( command ) )  end  end


function  main  ( argv )    --------------------------------------------  main

  os .execute ( 'clear' )
  print ( 'sacnning systemd units ...' )

  local  message  =
    '  "Please select the Systemd units you wish to stop and disable."  '

  local  command  =  {
    '  whiptail  --notags  --checklist  ',
    message,
    '  30 100 20  ',
    '  3>&1  >&2  2>&3  --  '  }

  local  units  =  list_unit_files()
  for  n, s  in  ipairs ( units )  do  repeat
    if  state(s) == 'disabled'  then  break  end
    insert ( command, n )
    insert ( command, ("'%s'") : format ( s ) )
    insert ( command, 0 )
    until 'once'  end

  local  f  =  io .popen ( concat ( command, '  ' ) )
  local  s  =  f : read 'a'
  f : close()
  os .execute ( 'clear' )

  for  v  in  s : gmatch ( '"(%d+)"' )  do
    local  line  =  units [ tonumber ( v ) ]
    local  unit  = line : match ( '^(%S+)' )
    stop_and_disable ( unit )  end  end


--  main  --------------------------------------------------------------  main


env_lock()

main ( {...} )
