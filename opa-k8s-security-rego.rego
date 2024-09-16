package main

deny[msg] {
    input.kind == "Service"
    input.spec.type != "NodePort"
    msg := "Service type should be NodePort"
}

deny[msg] {
    input.kind == "Deployment"
    not input.spec.template.spec.containers[0].securityContext.runAsNonRoot
    msg := "Containers must not run as root - use runAsNonRoot within container security context"
}
