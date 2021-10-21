

if [ -z "$(which terraform)"]; then
  echo "Please install terraform"
  exit 127
fi

init() {
  terraform init
}

lint() {
  tflint --init && tflint
}

test() {
  init

  terraform validate
}

plan() {
  init

  terraform workspace select $1
  terraform plan -var-file $1.tfvars
}

apply() {
  init

  terraform workspace select $1
  terraform apply -auto-approve -input=false -var-file $1.tfvars
}
