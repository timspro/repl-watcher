#!/usr/bin/env bash
# this may work on other shells but only bash was tested

# this script assumes two arguments are provided: the event and path strings as passed by the chokidar CLI

# listen for file changes only; not when files are added or deleted
if [ "$1" == 'change' ]; then

  # chokidar does not attempt to shut down the previous command if it's still running, so we need to do it
  # check to see if we can find the command's previously recorded process ID
  if [[ -f /tmp/repl.pid ]]; then
    # attempt to silently kill the previous command if we found record of the process ID
    kill `cat /tmp/repl.pid` 2> /dev/null
  fi

  # record the current command/shell's process ID; this will be the process ID for the REPL as well
  echo $$ > /tmp/repl.pid;

  # print a blank line to terminal to help separate different command invocations
  echo ""

  # this seems to be the only way to currenly import an ES6 module since Node's REPL must use dynamic imports,
  #   dynamic imports return promises, and eval expressions cannot use "await" at the top level 
  # normally, exposing the result of async code in this way is a race condition but since this is ultimately 
  #   being exposed to a user, the input delay for any dependent code will virtually guarantee this works
  JS="let $; (async () => { $ = await import('./$2').catch(err => console.error(err)); })()"

  # start the REPL with the JavaScript expression
  # since we use exec, the REPL gets the current shell's process ID
  # note that --experimental-repl-await is not strictly necessary since it does not affect how Node 
  #   deals with the JavaScript expression but is useful for importing other modules later in the REPL
  exec node --experimental-repl-await --interactive --eval "$JS"

fi