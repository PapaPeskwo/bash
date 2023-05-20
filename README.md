We have created a bash function called "updating", not an alias. When you use the alias command, it won't show functions, 
only aliases. To view your bash function, use the typeset -f or declare -f command:

```bash
typeset -f updating
```
or
```bash
declare -f updating
```

If updating has been correctly defined as a function, you should see the function's code when you run either of these commands.

To call your function, you can just type updating in the command line and press Enter.
