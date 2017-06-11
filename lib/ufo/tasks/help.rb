module Ufo::Tasks::Help
  def build
<<-EOL
Examples:

$ ufo tasks build

Builds all the task defintiions.

Note all the existing ufo/output generated task defintions are wiped out.
EOL
  end

  def register
<<-EOL
Examples:

$ ufo tasks register
All the task defintiions in ufo/output registered.
EOL
  end

  extend self
end
