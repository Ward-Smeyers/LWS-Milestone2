# Milestone 2: Run a "randomized" webstack on a Kubernetes cluster 

Create your own Kubernetes cluster and deploy the webstack which is assigned to you.

Koppelingen naar een externe site.

Details see these slides

Koppelingen naar een externe site..

Set up a web application stack consisting of 3 containers:

- A web frontend, serving a javascript web page (js code is provided to you)
- When  layout of webpage changes, the worker will display the new layout (automatically, or after an image rebuild)

- A FastAPI or Node.js service with
    + an API endpoint that gets your name
    + an API endpoint that gets the container ID
    + When the name changes in Db, webpage changes automatically (after a refresh)

    A backend database that stores the name

Points:

- 5/20 - stack in Docker
- 10/20 - kind or microk8s or minikube cluster with 1 worker that runs your stack

Plus EXTRA POINTS

- Enable HTTPS on k8s using a valid, public certificate (use cert-manager)->  +2 points

- Extra worker in your k8s cluster + scaling of API across nodes (show container id on frontend)  -> +2 points
- Monitor your cluster resources and performance using Prometheus -> +2 point
- Add an extra -> +4 points

    + Set up a Kubeadm cluster with 2 workers and 1 controller node, running and load balancing your stack.
    + OR

    + Use a Helm Chart to set up ArgoCD on your k8s cluster and implement a GitOps workflow to deploy your app automatically.

The rules:

- Don’t change or add anything after the deadline. You will show us the things that you have documented during the evaluation!

- Don’t copy each others document, we will use Turnitin to check for plagiarism.

- Use your initials for image, container names etc..

- Your document has a nice, professional layout and a proper introduction and conclusion.

- Document every step and command you enter to accomplish this. Use readable screenshots. Explain every parameter and option inside the commands as well. What does it do and why are you using it?
- Show your configuration files and explain all important lines.

# How can I use private docker image in github actions
https://stackoverflow.com/questions/64033686/how-can-i-use-private-docker-image-in-github-actions


# Prometheus monitoring 

https://devopscube.com/setup-prometheus-monitoring-on-kubernetes/
https://devopscube.com/setup-kube-state-metrics/
https://devopscube.com/setup-grafana-kubernetes/