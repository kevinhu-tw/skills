## Durable workflow changes

When the user states a durable workflow preference or correction ("from now on",
"going forward", "next time", "always", "never", "remember this", "make this the
default", "update the skill"), load the `reflect` skill and apply the smallest
patch to the relevant skill. If the statement is exploratory ("maybe", "what do
you think", "could we"), propose the patch and ask one question. If the message
also contains a task, finish that task first unless the change affects it.
