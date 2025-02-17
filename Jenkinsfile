pipeline {
    agent any
    
        environment {
            registry = '3.110.136.88:8085/repository/odoo17-main' // Nexus repo URL
            registryCredentials = 'nexus'                         // Nexus credentials in Jenkins
            imageName = 'odoo17-odoo-prod'                        // Docker image name
            dbImageName = 'postgres'
            imagetag = "${BUILD_NUMBER}"                          // Image tag
            NEXUS_USERNAME = credentials('nexus')                 // Get username from Jenkins credentials
            NEXUS_PASSWORD = credentials('nexus')                 // Get password from Jenkins credentials
            RECIPIENTS = "support@expertit.in"
         }
       
    stages {
        
        stage('Checkout Code') {
            steps {
            checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[credentialsId: 'odoo17_git', url: 'https://tushar-m@bitbucket.org/expertit-scloudx/test-prod.git']])
            }
        }
        
        stage('Update Docker Compose Image Tags') {
            steps {
                script {
                    sh "sed -i 's|odoo17-odoo-prod:latest|odoo17-odoo-prod:${BUILD_NUMBER}|g' docker-compose.yml"
                  }
                }
            }
        
        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker-compose build --no-cache"
                    sh "docker images"
                }
             }
         }
        
        stage('Verify Docker Images') {
            steps {
                script {
                    // Check if the Docker images are created
                    sh "docker images "
                    sh "docker ps "
                    sh "docker images | grep -E 'odoo17|postgres'"
                }
            }
        }
       
            stage('Push Image to Nexus') {
            steps {
                script {
                    def version = "${BUILD_NUMBER}" // Use Jenkins build number as tag
                    withCredentials([usernamePassword(credentialsId: 'nexus', usernameVariable: 'NEXUS_USERNAME', passwordVariable: 'NEXUS_PASSWORD')]) {
                    sh 'echo $NEXUS_PASSWORD | docker login 3.110.136.88:8085 --username $NEXUS_USERNAME --password-stdin'
                          // Push both the versioned image and the latest tag
                        sh "docker push ${registry}/${imageName}:${version}"
                        sh 'docker logout 3.110.136.88:8085'
                    }
                }
            }
        }

        stage('Deploy Database Container') {
            steps {
                script {
                    sh '''
                    NETWORK_NAME=odoo-network docker-compose up -d postgres-db
                    echo "Waiting for PostgreSQL to be ready..."
                    sleep 10
                    '''
                }
            }
        }
        
        stage('Deploy Odoo Container') {
            steps {
                script {
                    try {
                        withCredentials([usernamePassword(credentialsId: 'nexus', usernameVariable: 'NEXUS_USERNAME', passwordVariable: 'NEXUS_PASSWORD')]) {
                            sh '''
                                echo $NEXUS_PASSWORD | docker login 3.110.136.88:8085 --username $NEXUS_USERNAME --password-stdin
        
                                # Stop and remove the old container
                                docker stop odoo-prod || true
                                docker rm odoo-prod || true
                                # Run the new image
                                docker run -d --name odoo-prod \
                                    --restart always \
                                    --network odoo-network \
                                    -p 8070:8069 -p 8071:8072 \
                                    -e ODOO_DATABASE_NAME=prod-odoo \
                                    -v odoo_prod_data:/var/lib/odoo \
                                    3.110.136.88:8085/repository/odoo17-main/odoo17-odoo-prod:${BUILD_NUMBER}
        
                                docker logout 3.110.136.88:8085
                            '''
                        }
                    } catch (Exception e) {
                        echo "New deployment failed! Rolling back to the previous image..."
        
                        // Find the previous working image
                        def previousImage = sh(script: "docker images --format '{{.Repository}}:{{.Tag}}' | grep 'odoo17-odoo-prod' | awk 'NR==2'", returnStdout: true).trim()
                         echo "previousImage"
                        if (previousImage) {
                            sh '''
                                echo "Rolling back to $previousImage..."
                                docker run -d --name odoo-prod \
                                    --restart always \
                                    --network odoo-network \
                                    -p 8070:8069 -p 8071:8072 \
                                    -e ODOO_DATABASE_NAME=prod-odoo \
                                    -v odoo_prod_data:/var/lib/odoo \
                                    $previousImage
                            '''
                        } else {
                            error "No previous image found! Manual intervention required."
                        }
                    }
                }
            }
        }
        


        // stage('Deploy Odoo Container') {
        //     steps {
        //         script {
        //             try {
        //                 withCredentials([usernamePassword(credentialsId: 'nexus', usernameVariable: 'NEXUS_USERNAME', passwordVariable: 'NEXUS_PASSWORD')]) {
        //                     sh '''
        //                         echo $NEXUS_PASSWORD | docker login 3.110.136.88:8085 --username $NEXUS_USERNAME --password-stdin

        //                         # Stop and remove the old container
        //                         docker stop odoo-prod || true
        //                         docker rm odoo-prod || true

        //                         # Run the new image
        //                         docker run -d --name odoo-prod \
        //                             --restart always \
        //                             --network odoo-network \
        //                             -p 8070:8069 -p 8071:8072 \
        //                             -e ODOO_DATABASE_NAME=prod-odoo \
        //                             -v odoo_prod_data:/var/lib/odoo \
        //                             3.110.136.88:8085/repository/odoo17-main/odoo17-odoo-prod:${BUILD_NUMBER}

        //                         docker logout 3.110.136.88:8085
        //                     '''
        //                 }
        //                 sendEmail("SUCCESS", "Deployment Successful for Build ${BUILD_NUMBER}")
        //             } catch (Exception e) {
        //                 echo "New deployment failed! Rolling back to the previous image..."

        //                 // Find the previous working image
        //                 def previousImage = sh(script: "docker images --format '{{.Repository}}:{{.Tag}}' | grep 'odoo17-odoo-prod' | awk 'NR==2'", returnStdout: true).trim()

        //                 if (previousImage) {
        //                     sh '''
        //                         echo "Rolling back to $previousImage..."
        //                         docker stop odoo-prod || true
        //                         docker rm odoo-prod || true

        //                         docker run -d --name odoo-prod \
        //                             --restart always \
        //                             --network odoo-network \
        //                             -p 8070:8069 -p 8071:8072 \
        //                             -e ODOO_DATABASE_NAME=prod-odoo \
        //                             -v odoo_prod_data:/var/lib/odoo \
        //                             $previousImage
        //                     '''
        //                 } else {
        //                     error "No previous image found! Manual intervention required."
        //                 }

        //                     sendEmail("FAILURE", "Deployment Failed for Build ${BUILD_NUMBER}. Rolled back to the previous version.")
        //                 }
        //             }
        //         }
        //     }


        // def sendEmail(String status, String message) {
        //     emailext (
        //         subject: "[Jenkins] Odoo Deployment ${status}",
        //         body: "${message}",
        //         to: "${RECIPIENTS}",
        //         attachLog: true
        //     )
        // }

       
    }
}
