pipeline {
    agent {
        kubernetes {
            yamlFile 'agent.yaml'
        }
    }
    environment {
        // Variables según convención de nombres
        NAMESPACE = 'ns-manuel-diaz'
        APP_NAME = 'tarea-final'
        TAG = 'manuel-diaz'
        APP_VERSION = '3.0.0' // Versión solicitada
        // ID de credenciales 
        DOCKER_CREDS = 'docker-hub-credentials'
    }
    stages {
        stage('Preparar Herramientas') {
            steps {
                container('node-docker-kubectl') {
                    sh '''
                        echo "Instalando kubectl..."
                        curl -LO "https://dl.k8s.io/release/v1.30.0/bin/linux/amd64/kubectl"
                        chmod +x kubectl
                        mv kubectl /usr/local/bin/
                
                        # Verificación
                        kubectl version --client
                    '''
                }
            }
        }
        stage('Install') {
            steps {
                container('node-docker-kubectl') {
                    sh 'npm install -g pnpm && pnpm install --frozen-lockfile --ignore-scripts'
                }
            }
        }
        stage('Test') {
            steps {
                container('node-docker-kubectl') {
                    sh 'pnpm test'
                }
            }
        }
        stage('Build') {
            steps {
                container('node-docker-kubectl') {
                    script {
                        // Construimos usando el nombre
                        sh "docker build -t manueldiazperalta/${APP_NAME}:${TAG} ."
                        // Etiquetamos también con la versión 3.0.0
                        sh "docker tag manueldiazperalta/${APP_NAME}:${TAG} manueldiazperalta/${APP_NAME}:${APP_VERSION}"
                    }
                }
            }
        }
        stage('Push') {
            steps {
                container('node-docker-kubectl') {
                    // CORRECCIÓN: El bloque script permite usar la API de docker de Jenkins
                    script {
                        docker.withRegistry('', env.DOCKER_CREDS) {
                            sh "docker push manueldiazperalta/${APP_NAME}:${TAG}"
                            sh "docker push manueldiazperalta/${APP_NAME}:${APP_VERSION}"
                        }
                    }
                }
            }
        }
        stage('Deploy') {
            steps {
                container('node-docker-kubectl') {
                    // Aplicamos el despliegue al namespace correspondiente
                    sh "kubectl apply -f entrega.yaml -n ${NAMESPACE}"
                    // Rollout status para asegurar que la app desplegó bien
                    sh "kubectl rollout status deployment/app-manuel-diaz -n ${NAMESPACE}"
                }
            }
        }
    }
}
