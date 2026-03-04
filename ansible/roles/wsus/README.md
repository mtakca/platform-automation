# WSUS Ansible Role

This role configures Windows Server Update Services (WSUS) settings on Windows clients.

## Features

- **Registry Config**: Sets WSUS server URL in Windows Registry.
- **Update Policy**: Configures auto-update behavior.

## Requirements

- Windows Server 2019/2022
- Ansible Windows modules (`ansible.windows`)

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `wsus_content_dir` | `D:\WSUS` | Path to store updates |
| `wsus_update_languages` | `['en']` | Languages to download |

## Example Playbook

```yaml
- hosts: wsus
  roles:
    - role: wsus
      vars:
        wsus_content_dir: "E:\Updates"
```
