#!/bin/bash
repo_dir="/1tb"
previous_state="$repo_dir/previous_state"
current_state="$repo_dir/current_state"
to_transfer_dir="$repo_dir/transfers"
current_date=$(date +%m.%d.%Y)
to_transfer_dir="$to_transfer_dir/$current_date"
mkdir -p "$to_transfer_dir"
reposync -p "$repo_dir"
find "$repo_dir" -name '*.rpm' > "$current_state"
rpm_list_file="$to_transfer_dir/rpm_list.txt"
> "$rpm_list_file" # Clears the file if it exists, or creates it if it doesn't
if [ -f "$previous_state" ]; then
    new_rpms=$(comm -13 "$previous_state" "$current_state")
    echo "New or updated RPMs:"
    echo "$new_rpms"
    for rpm in $new_rpms; do
        cp "$rpm" "$to_transfer_dir"
        echo "$(basename "$rpm")" >> "$rpm_list_file"
    done
else
    echo "No previous state found. Copying all RPMs."
    for rpm in $(find "$repo_dir" -name '*.rpm'); do
        cp "$rpm" "$to_transfer_dir"
        echo "$(basename "$rpm")" >> "$rpm_list_file"
    done
fi
mv "$current_state" "$previous_state"
