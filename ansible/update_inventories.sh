#!/bin/bash

# Paths and Variables
TERRAFORM_OUTPUT_DIR="../terraform"        # Assuming terraform/ is one level above ansible/
ANSIBLE_INVENTORY_DIR="./inventories"      # We are in ansible/

# Create inventory folders if not exist
mkdir -p "$ANSIBLE_INVENTORY_DIR/dev"
mkdir -p "$ANSIBLE_INVENTORY_DIR/stg"
mkdir -p "$ANSIBLE_INVENTORY_DIR/prod"

# Navigate to the Terraform directory
cd "$TERRAFORM_OUTPUT_DIR" || { echo "Terraform directory not found"; exit 1; }

# Ensure jq is installed
if ! command -v jq &> /dev/null; then
    echo "jq is required but not installed. Install with: sudo apt install -y jq"
    exit 1
fi

# Fetch IPs from Terraform outputs
DEV_IPS=$(terraform output -json dev_infra_ec2_public_ips | jq -r '.[]')
STG_IPS=$(terraform output -json stg_infra_ec2_public_ips | jq -r '.[]')
PRD_IPS=$(terraform output -json prd_infra_ec2_public_ips | jq -r '.[]')

# Go back to ansible dir
cd - > /dev/null

# Function to update inventory file
update_inventory_file() {
    local ips="$1"
    local inventory_file="$2"
    local env="$3"

    > "$inventory_file"  # Create or clear file

    echo "[servers]" >> "$inventory_file"
    local count=1
    for ip in $ips; do
        echo "server${count} ansible_host=$ip" >> "$inventory_file"
        count=$((count + 1))
    done

    echo "" >> "$inventory_file"
    echo "[servers:vars]" >> "$inventory_file"
    echo "ansible_user=ubuntu" >> "$inventory_file"
    echo "ansible_ssh_private_key_file=../terraform/tws-terra-key" >> "$inventory_file"
    echo "ansible_python_interpreter=/usr/bin/python3" >> "$inventory_file"

    echo "✅ Updated $env inventory: $inventory_file"
}

# Call function
update_inventory_file "$DEV_IPS" "$ANSIBLE_INVENTORY_DIR/dev/hosts" "dev"
update_inventory_file "$STG_IPS" "$ANSIBLE_INVENTORY_DIR/stg/hosts" "stg"
update_inventory_file "$PRD_IPS" "$ANSIBLE_INVENTORY_DIR/prod/hosts" "prd"

echo "✅ All inventory files updated successfully!"









# #!/bin/bash

# # Paths and Variables
# TERRAFORM_OUTPUT_DIR="../terraform"  # Replace with the actual Terraform directory path
# ANSIBLE_INVENTORY_DIR="./inventories"

# # Navigate to the Terraform directory
# cd "$TERRAFORM_OUTPUT_DIR" || { echo "Terraform directory not found"; exit 1; }

# # Fetch IPs from Terraform outputs
# DEV_IPS=$(terraform output -json dev_infra_ec2_public_ips | jq -r '.[]')
# STG_IPS=$(terraform output -json stg_infra_ec2_public_ips | jq -r '.[]')
# PRD_IPS=$(terraform output -json prd_infra_ec2_public_ips | jq -r '.[]')

# # Function to update inventory file
# update_inventory_file() {
#     local ips="$1"
#     local inventory_file="$2"
#     local env="$3"

#     # Create or clear the inventory file
#     > "$inventory_file"

#     # Write the inventory header
#     echo "[servers]" >> "$inventory_file"

#     # Add dynamic hosts based on IPs
#     local count=1
#     for ip in $ips; do
#         echo "server${count} ansible_host=$ip" >> "$inventory_file"
#         count=$((count + 1))
#     done

#     # Add common variables
#     echo "" >> "$inventory_file"
#     echo "[servers:vars]" >> "$inventory_file"
#     echo "ansible_user=ubuntu" >> "$inventory_file"
#     echo "ansible_ssh_private_key_file=saitama@BOOKLET/Terraform_Ansible_Env/terraform/tws-terra-key" >> "$inventory_file"
#     echo "ansible_python_interpreter=/usr/bin/python3" >> "$inventory_file"

#     echo "Updated $env inventory: $inventory_file"
# }

# # Update each inventory file
# update_inventory_file "$DEV_IPS" "$ANSIBLE_INVENTORY_DIR/dev" "dev"
# update_inventory_file "$STG_IPS" "$ANSIBLE_INVENTORY_DIR/stg" "stg"
# update_inventory_file "$PRD_IPS" "$ANSIBLE_INVENTORY_DIR/prd" "prd"

# echo "All inventory files updated successfully!"
