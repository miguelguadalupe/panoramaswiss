#!/bin/bash

#Created By MGuadalupe

# Function to convert CIDR to Subnet Mask
cidr_to_netmask() {
    local i mask=""
    local full_octets=$(($1/8))
    local partial_octet=$(($1%8))

    for ((i=0; i<4; i++)); do
        if [ $i -lt $full_octets ]; then
            mask+=255
        elif [ $i -eq $full_octets ]; then
            mask+=$((256 - 2**(8-$partial_octet)))
        else
            mask+=0
        fi
        test $i -lt 3 && mask+=.
    done

    echo $mask
}



# Function for fgmassconfig script
pamassconfig() {
    clear -x

    echo "This function is created to facilitate the address creation on the firewalls."
    echo
    # Prompt the user for the name of the IP address object and address group
    read -p "Provide device-group: " device_group
    read -p "Enter the name of the IP address object: " ip_object_name

    clear -x
    # Open nano to edit the IP list file
    nano ip_list.txt
    cat ip_list.txt | sort -u > temp.txt && mv temp.txt ip_list.txt

    # Read the contents of the IP list file
    ip_list=$(cat ip_list.txt)

    # Store the output in a variable
    output=""

    # Iterate through each IP address in the list
    for entry in $ip_list; do
        if [[ $entry == *"/"* ]]; then
            # Directly use the entry which includes IP address and CIDR
            ip_cidr=$entry
            # Replace "/" with "-" in the entry for the name
            name_entry="${entry//\//-}"
        else
            # Assume /32 for IP addresses without a specified CIDR
            ip_cidr="${entry}/32"
            name_entry=$entry
        fi

        # Append the configuration command with IP/CIDR to the output variable
        # Use modified name_entry which replaces "/" with "-"
        output+="set device-group $device_group address "$ip_object_name-$name_entry" ip-netmask $ip_cidr"$'\n'
    done

    # Display the generated configuration
    echo "======================START OF Configuration======================" | lolcat
    echo
    echo "$output" | lolcat

    echo

# After generating $output

# Extract the names and replace commas with spaces if needed
# Make sure to replace "/" with "-" in grep command to match the updated naming
filtered_names=$(echo "$output" | grep -oP 'address \K[^ ]+' | sed 's/\//-/g' | tr '\n' ' ')

# Prepare the final output line
output2="set device-group $device_group address-group XXXXXXXXXXX static [ $filtered_names]"

# Use lolcat for colorful display, if that's part of your requirements
echo "$output2" | lolcat
echo
echo "======================END OF Configuration======================" | lolcat
    rm ip_list.txt
    read -p "Press ENTER to finish: "
}


# function for FQDN
FQDN() {


    clear -x
    read -p "Provide device-group: " device_group

    # Open nano to edit the IP list file
    nano ip_list.txt
    cat ip_list.txt | sort -u > temp.txt && mv temp.txt ip_list.txt

    # Read the contents of the IP list file
    ip_list=$(cat ip_list.txt)

    # Store the output in a variable
    output=""

    # Iterate through each IP address in the list
    for ip in $ip_list; do
        # Append the configuration command with IP/CIDR to the output variable

        output+="set device-group $device_group address "$ip" fqdn $ip"$'\n'

        done


    # Display the generated configuration
    echo "======================START OF Configuration======================" | lolcat
    echo
    echo "$output" | lolcat
    echo
    echo "Append if needed"
    echo

    filtered_names=$(echo "$output" | grep -oP 'address \K[^ ]+' | tr '\n' ' ')

    # Prepare the final output line
    output2="set device-group $device_group address-group XXXXXXXXXXX static [ $filtered_names]"


    echo "$output2" | lolcat
    echo
    echo "======================END OF Configuration======================" | lolcat

    rm ip_list.txt

    read -p "Press ENTER to finish "
}







# Function to display the menu
display_menu() {
    menu_text="

    Hello, $USER!
    Welcome to paswiss
   *--------------------*
   | 1) PA Address      |
   | 2) FQDN            |
   |                    |
   | q) Exit            |
   *--------------------*
"
    echo -e "$menu_text" | lolcat
}

# Main loop
while true; do
    clear -x
    display_menu
    read -p "Please Select a value: " -n 1 val
    case "$val" in
        1) pamassconfig;;
        2) FQDN;;
        q) break;;
        *) clear
           echo "Invalid option. Try again.";;
    esac
    sleep 0.8
done
