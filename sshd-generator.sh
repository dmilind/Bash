#!/usr/bin/env bash 

# sshd-generator script to keep sshd_config file updated always. This program parses all files provided under /etc/ssh/allowed_groups, collects all group, and all those groups will be added
# AllowGroups in sshd_config file. Also this will make sure not to add duplicate value in sshd_config.
#
# Maintainer: Milind Dhoke
# 

# ag_files_dir
ag_files_dir="/etc/ssh/allowed_groups/"
sshd_config_file="/etc/ssh/sshd_config"

# function to throw an error on unsuccessful execution.
error_out() {
    if [ $? -ne 0 ]; then
        echo "$1"
        exit 1
    fi 
}

# func to collect all groups from all files -- all raw goups are stored in component_groups[]
groups_collector() {
    for file in "${component_files[@]}" 
    do 
        echo "  Collecting groups from a file --> [ $file ]"
        while IFS= read -r line 
        do 
            component_groups+=("$line")
        done < "$ag_files_dir$file"
    done
}

# sorting all groups in a alphabetical order --> all sorted groups are stored in sorted_groups[]
groups_sorter() {   
    IFS=$'\n' 
    sorted_groups=($(sort <<<"${component_groups[*]}"))
    unset IFS
    echo "Sorted groups from all component files are --> [ ${sorted_groups[@]} ]"
}

# remove all duplicate entries from the sorted groups array --> all unique sorted groups are stored in unique_sorted_groups[]
groups_duplicate_remover() {
    IFS=$'\n'
    unique_sorted_groups=($(sort -u <<<"${sorted_groups[*]}"))
    unset IFS
    echo "Required sshd groups to be pushed in sshd_config file are --> [ ${unique_sorted_groups[@]} ]"
}

# updating sshd_config with unique sorted groups collected from all component files
sshd_config_updator() {
    all_component_groups="${unique_sorted_groups[@]}"
    if [ -f /etc/ssh/sshd_config.tmp ]; then
        rm -f /etc/ssh/sshd_config.tmp 
    fi 
    # write sshd_config.tmp by taking each line from sshd_config.template but not AllowGroup.
    while IFS= read -r line 
    do 
        if [ "$line" != "AllowGroups" ]; then
            echo "$line" >>  /etc/ssh/sshd_config.tmp 
        fi
    done < /etc/ssh/sshd_config.template
    # append AllowGroups $all_component_groups to the end of file 
    echo "AllowGroups $all_component_groups" >> /etc/ssh/sshd_config.tmp 
    cp -f /etc/ssh/sshd_config.tmp /etc/ssh/sshd_config
}

# main 
# check directory exists or not --> /etc/ssh/allowed_groups/
if [ ! -d "$ag_files_dir" ]; then
    error_out "Missing directory '$ag_files_dir' which stores component files"
fi
# backing up current sshd_config file
cp -f /etc/ssh/sshd_config /etc/ssh/sshd_config.back
# find all files from  this directory and list those in an array --> all component files are stored in component_files[]
i=0
while read line 
do  
    component_files[ "$i" ]="$line"
    (( i++ ))
done < <(ls  $ag_files_dir) 
echo "Available component files are --> [ ${component_files[@]} ]"

# collect all groups from all component files
groups_collector
error_out "Error while collecting groups from all component files"

# sort all collected groups in alphabetical order
groups_sorter
error_out "Error while sorting groups alphabetically"

# remove duplicate groups from list of sorted groups
groups_duplicate_remover
error_out "Error while removing duplicate entries from groups"

# Update sshd_config file and add all list of sorted unique groups from all component files
sshd_config_updator
if [ $? -eq 0 ]; then
    systemctl restart sshd 
    if [ $? -eq 0 ]; then
        echo "Updated sshd_config file and restarted sshd service successfully "
    else
        error_out "Error occured while restarting sshd service after updating sshd_conf file, reverting changes and restarting sshd"
        cp -f /etc/ssh/sshd_config.back /etc/ssh/sshd_config
        systemctl restart sshd 
    fi 
else
    error_out "Error occured while updating sshd_config file"
fi
rm -f /etc/ssh/sshd_config.tmp 


