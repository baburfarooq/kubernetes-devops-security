package main

deny[message] {
    input.kind == "Service"
    input.spec.type != "NodePort"
    message = "Service type should be NodePort"
}

deny[message] {
    input.kind == "Deployment"
    input.spec.template.spec.containers[0].securityContext.runAsNonRoot != true
    message = "Containers must not run as root - use runAsNonRoot within container security context"
}
