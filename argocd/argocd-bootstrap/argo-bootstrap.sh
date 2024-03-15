#!/bin/bash

#set -euo pipefail # -u: unset variables cause an error.
# -e: abort execution if any command return exit code != 0
# -o pipefail: If any command in a pipeline fails, that return code will be used as the return code of the whole pipeline

argo_appset_manifest="../applicationsets/tools/argocd/applicationset.yaml"
root_app_manifest="../applications/root/application.yaml"
namespace="$(grep "^  namespace:" $argo_appset_manifest | awk '{print $2}' | sed 's/"//g')"
helm_release="$(grep "releaseName" $argo_appset_manifest | awk '{print $2}' | sed 's/"//g')"
chart_repo="$(grep "chart:" -B2 $argo_appset_manifest | grep repoURL | awk '{print $3}')"
chart_name="$(grep "chart:" $argo_appset_manifest | awk '{print $2}')"
chart_version="$(grep "chart:" -A2 $argo_appset_manifest | grep targetRevision | awk '{print $2}' | sed 's/"//g')"

print_vars() {
	echo $argo_appset_manifest
	echo $root_app_manifest
	echo $namespace
	echo $helm_release
	echo $chart_repo
	echo $chart_name
	echo $chart_version
}

create_ns() {
	if kubectl get namespace "$namespace" &>/dev/null; then
		echo "Namespace '$namespace' exists."
	else
		echo "Namespace '$namespace' does not exist. Creating..."
		kubectl create namespace "$namespace"
	fi
}

# Install ArgoCD
install_argo() {
	helm upgrade "$helm_release" "$chart_name" --install \
		--version "$chart_version" \
		--dependency-update \
		--description "ArgoCD" \
		--output table \
		--wait \
		--wait-for-jobs \
		--repo "$chart_repo" \
		--namespace "$namespace" \
		--create-namespace
}

apply_root_app() {
	kubectl apply -f "$root_app_manifest"
}

# Get default admin password
output_admin_password() {
	echo "-------------------"
	echo "Initial ArgoCD Admin Password:"
	kubectl -n argocd get secret argocd-initial-admin-secret \
		-o jsonpath="{.data.password}" | base64 -d
	echo
	echo "-------------------"
}

# expose argocd service and access it on https://localhost:8080
port_forward() {
	echo "ArgoCD Web UI accessible through http://localhost:8080"
	kubectl port-forward -n argocd service/argocd-server 8080:80
}

main() {
	print_vars
	create_ns
	install_argo
	apply_root_app
	output_admin_password
	port_forward
}

main
