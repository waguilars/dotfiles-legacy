# run-secure

Inject a token stored in [pass](https://www.passwordstore.org/) into a single
command's environment, without printing the token, exporting it in the calling
shell, or placing it in argv.

## Synopsis

```text
run-secure ENV_NAME PASS_KEY COMMAND [ARGS...]
```

- `ENV_NAME` — environment variable name the token is exposed under
- `PASS_KEY` — pass entry path; its **first line** is the token
- `COMMAND [ARGS...]` — command to run with the injected environment

## Behavior

The wrapper retrieves the entry with `pass show --`, takes the first line as
the token, assigns it to `ENV_NAME`, and then runs the command with
`exec --`, so arguments are preserved verbatim and the exit status is the
command's own. Leading-dash keys and leading-dash commands are passed after
`--` and are never parsed as options.

The script fails closed (nonzero exit, command never runs) when:

- fewer than three arguments are given
- `ENV_NAME` is not a valid shell variable name
- `ENV_NAME` is a reserved Bash name (see below)
- `pass` is not available in `PATH`
- the pass retrieval fails
- the entry's first line is empty

Shell tracing (`set -x`, `bash -x run-secure ...`) is disabled before any
secret is read, so the token can never appear in a trace.

## Reserved names

`ENV_NAME` must not be a Bash-managed or integer-typed variable. Exporting a
secret into those names would either mutate shell control state or make Bash
evaluate the value and echo it in a diagnostic. The following are rejected
before retrieval:

- `BASH*` — every Bash-managed name, including `BASH_ENV`, `BASHOPTS`,
  `BASH_XTRACEFD`, `BASH_VERSION`
- `SHELLOPTS` — shell options control variable
- `UID`, `EUID`, `PPID` — read-only shell internals
- `RANDOM`, `SECONDS`, `LINENO`, `HISTCMD`, `OPTIND`, `SHLVL` — integer-typed
  specials whose values Bash evaluates arithmetically

## Internal variable hygiene

All wrapper-internal variables use the `_run_secure_` prefix and are kept
unexported. At startup the wrapper unsets any inherited exported internal
name, so an inherited exported `_run_secure_entry` can never leak the full
multiline entry, and an inherited exported `_run_secure_token` can never
appear as a duplicate in the child environment. Auto-export (allexport,
including one imported from an inherited `SHELLOPTS`) is switched off for the
whole run. Requesting an internal-sounding name such as `_run_secure_entry`
explicitly is supported and yields exactly one exported variable.

## Examples

```bash
# Expose a service token to a client that reads it from its environment
run-secure API_TOKEN services/example/api ./client --token-from-env
```

```bash
# Hand a token to a script
run-secure DEPLOY_TOKEN servers/deploy/myhost ./deploy.sh --host myhost
```

## Environment visibility caveat

The token is visible to anything the launched process can reach: it inherits
`ENV_NAME` normally, any child process it spawns also inherits it, and it can
be read from that process tree (for example, `/proc/<pid>/environ` for
same-user processes) or printed by tools that dump the environment. Run
commands that consume the variable directly from the environment.

Do not interpolate the variable into parent-shell command arguments (for
example, `curl -H "Authorization: Bearer $API_TOKEN"`): the expansion happens
in the parent and the secret ends up in the command's argv, where other
same-user processes can read it. Prefer tools that read the variable from
their environment natively.

## Tests

```bash
bash -n bin/run-secure
bash -n tests/run-secure.sh
bash tests/run-secure.sh
```

The test suite uses a fake `pass` stub and fake secrets only; it never reads a
real password store.
