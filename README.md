# Secrets Tool
This is a small tool which helps to encrypt secrets that must be committed to a Git repository.

It has the advantage to natively support partial encryption of YAML files. This is of great advantage, as it allows to see the YAML file structure even when some of its contents are encrypted (your PR reviewers and diff tools will thank you)

## Prerequisites
* Python >= 3.7
* Having the following packages installed: `pip install ruamel.yaml cryptography`

## Usage
The tool reads a list of files to encrypt/decrypt from a `.gitignore` file. In there it will only consider files that are sorrounded by a comment block as in the following example:

```
# BEGIN ENCRYPTED
kaas-rubik-stage/values.yaml
# END ENCRYPTED
```

Run the tool by giving the `.gitignore` file as an argument, together with either a `encrypt` or `decrypt` command:

```
cd <REPOSITORY_ROOT>
python -m utils.secrets_tool k8s_helm/.gitignore encrypt
```

## Syntax
The tool provides different encryption handlers for all kind of file types.
* `yaml` for YAML files that are used by tools which are okay having a `!decrypted` tag in front of strings
* `yamlcompat` for tools that don't like the additional 'encryption marker' tag.
* `generic` for all other file types. It encrypts the complete file.

The desired encryption handler is inferred from the filetype - or it can be given explicitly in the gitignore file using the `# type:` hint:

```
# BEGIN ENCRYPTED
kaas-rubik-stage/values.yaml

# type: yaml
kaas-rubik-stage/values2.txt
# END ENCRYPTED
```

### yamlcompat
This encryption handler can encrypt individual YAML keys without relying on 'parser visible' changes in the YAML file structure.
Instead of marking the desired keys directly in the file, they are listed in the .gitignore file using a `# data: ` comment:

```
# BEGIN ENCRYPTED
kaas-rubik-stage/values.yaml

# type: yamlcompat
# data: splunk.apiToken
# data: splunk.host
kaas-rubik-stage/values2.yaml
# END ENCRYPTED
```

*WARNING* It is recommended to use the normal YAML handler whenever possible. When using the yamlcompat module, you split up your encryption logic over multiple files, which might lead to errors (especially on fragile YAML files that contain unnamed structures - like lists)
