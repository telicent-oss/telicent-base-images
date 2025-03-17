import requests
from pathlib import Path

def get_image_descriptor_files():
    project_root = Path(__file__).resolve().parent

    image_descriptors_dir = project_root / 'image-descriptors'

    if not image_descriptors_dir.exists():
        raise FileNotFoundError(f"'image-descriptors' directory not found in {project_root}")

    files = list(image_descriptors_dir.rglob('*'))

    file_paths = [str(file.resolve()) for file in files if file.is_file()]

    return file_paths

def get_latest_non_sha_non_source(tags):
    filtered_tags = [
        tag for tag in tags
        if not tag.startswith("sha256-") and "source" not in tag and tag != "latest"
    ]

    sorted_tags = sorted(filtered_tags, reverse=True)

    return sorted_tags[0] if sorted_tags else None


def update_image_version(file_path, registry_url, image_name):
    response = requests.get(f"{registry_url}/{image_name}/tags/list")
    response.raise_for_status()
    tags = response.json().get("tags", [])
    latest_tag = get_latest_non_sha_non_source(tags)

    with open(file_path, "r") as file:
        lines = file.readlines()

    updated_lines = []
    for line in lines:
        if line.strip().startswith("from:"):
            key, value = line.strip().split(": ")
            image_prefix, current = value.strip('"').split(':')
            cver, ctag = current.split('-')
            lver, ltag = latest_tag.split('-')

            cver = float(cver)
            ctag = int(ctag)
            lver = float(lver)
            ltag = int(ltag)

            if (lver - cver) >= 0:
                if ltag == ctag and lver == cver:
                    print(f"Nothing to update, current descriptor version is {current}, latest remote version is {latest_tag}")
                    return
                elif ltag < ctag and lver == cver:
                    raise AttributeError(f"Cannot update version with older tag. Current={ctag}, Candidate={ltag}")
            else:
                raise AttributeError(f"Cannot update version older than the current one. Current={cver}, Candidate={lver}")

            updated_line = f'{key}: "{image_prefix}:{latest_tag}"\n'
            updated_lines.append(updated_line)
            print(f"Updated {value} to {image_prefix}:{latest_tag}")
        else:
            updated_lines.append(line)

    with open(file_path, "w") as file:
        file.writelines(updated_lines)

    print(f"Updated {file_path} to use {image_name}:{latest_tag}")

# Checks against Redhat Registry for image. Use descriptor-updater-alternative.sh fo Docker hub.
if __name__ == '__main__':
    registry_url = "https://registry.access.redhat.com/v2"
    image_name = "ubi9-minimal"

    for file_path in get_image_descriptor_files():
        update_image_version(file_path, registry_url, image_name)