---
title: "AWS - Retours de veille"
date: 2017-01-05T07:40:54+01:00
draft: true
authors: ["djlechuck"]
tags: ["api-rest", "aws", "elastic-beanstalk", "swagger"]
categories: ["veille-et-tests"]
---

## Avant-propos

Cet article explique les tests effectués pour mettre en place une API REST en
utilisant plusieurs services Amazon. Le but n’est pas de donner une solution
clef en main sur quoi utiliser mais de défricher un peu les différents services
existants et le rôle qu’ils jouent dans cette architecture.

Tout ce qui est dit ici ne reflète que mes recherches personnelles et ne
saurait être pris pour argent comptant car je ne saurais dire si c’est ce sont
les meilleurs utilisations que je fais et si elles sont fiables.

Je vais donc dans un premier temps expliquer grossièrement à quoi sert chaque
service, puis j’expliquerais l’architecture que j’ai essayé de mettre en place
et enfin je terminerais par exposer mes recommandations actuelles pour mettre
en place une API avec les besoins qu'avait mon entreprise à ce moment.

## Services testés

### Amazon

#### API Gateway

**Documentation :** [API Gateway](https://aws.amazon.com/fr/api-gateway/)

**Présentation :** Service permettant de publier, gérer, surveiller et
sécuriser facilement des API. Il gère le traitement de tous les appels
effectués, les droits d’accès, la surveillance, la gestion des versions de
l’API.

#### Elastic Beanstalk

**Documentation :** [Elastic Beanstalk](https://aws.amazon.com/fr/elasticbeanstalk/)

**Présentation :** Service permettant de déployer et dimensionner facilement
des applications et services web développés avec Java, .NET, PHP, Node.js,
Python, Ruby, Go et Docker. Il gère l’équilibre de charge, le dimensionnement
des capacités, la surveillance et l’état de l’application. Simplifié par EB
dans la suite du document.

#### Lambda

**Documentation :** [Lambda](https://aws.amazon.com/fr/lambda/)

**Présentation :** Service permettant d’exécuter du code sans avoir à gérer de
serveur. Il gère le dimensionnement et l’aspect hautement disponible du code.
Le code est stateless.

#### DynamoDB

**Documentation :** [DynamoDB](https://aws.amazon.com/fr/dynamodb/)

**Présentation :** Service de base de données NoSQL. Il gère la répartition des
données et du trafic de manière automatique.

#### IAM (Identity and Access Management)

**Documentation :** [IAM (Identity and Access Management)](https://aws.amazon.com/fr/iam/)

**Présentation :** Service permettant de gérer et contrôler l’accès à tous les
autres services utilisés via une notion de rôle, groupe et utilisateur.

#### Certificate Manager

**Documentation :** [Certificate Manager](https://aws.amazon.com/fr/certificate-manager/)

**Présentation :** Service proposant des certificats SSL à utiliser avec
certains applicatifs AWS tel que CloudFront ou Elastic Load Balancer.

#### S3

**Documentation :** [S3](https://aws.amazon.com/fr/s3/)

**Présentation :** Service de stockage de fichiers avec gestion de droits
d’accès, de haute disponibilité.

### Autres

#### Swaggerhub

**Documentation :** [Swaggerhub](https://swaggerhub.com/integrations/)

**Présentation :** Service de design d’API proposant un ensemble de service qui
facilite la génération de code client / serveurs, la génération de
documentation utilisateur et l’intégration automatique à des services tel
qu’Amazon API Gateway.

#### mLab

**Documentation :** [mLab](http://docs.mlab.com/)

**Présentation :**  Service de base de données NoSQL. Il gère lui-même le
serveur de BDD sur des instances AWS, Google Cloud Platform ou Microsoft Azure.

## Architecture testée

![AWS - Schéma architecture testée](/images/aws-schema-architecture-testee.png)

La première étape consiste à designer l’API avec Swagger. Pour se faire,
Swaggerhub propose un éditeur en ligne qui permet de voir en tant réel le
pré-rendu de la documentation utilisateur à mesure que l’on définit l’API et
permet également de faciliter l’intégration sur le service API Gateway d’Amazon
via un processus de synchronisation manuel ou à chaque sauvegarde de
modification.

L’implémentation sur API Gateway peut se faire sous 2 formes : sans
pré-configuration ou avec une pré-configuration pour utiliser le service
Lambda en plus. Le déploiement utilise IAM pour sécuriser la création ; Il
faut donc créer un rôle qui se chargera de générer l’API sur API Gateway.

Une fois l’API déployée, il faut la configurer quelques points. Tout d’abord,
on peut générer un certificat client qui servira à signer les appels effectués
par API Gateway. On peut également configurer un nom de domaine personnalisé
afin d’utiliser https://api.monsite.fr/users au lieu de
https://11xxx2xxx.execute-api.eu-west-1.amazonaws.com/dev. Il y a tout un tas
d’autres possibilités que je n’exposerai pas ici car cela sort du cadre de mes
tests.

Vient ensuite le choix entre utiliser API Gateway conjointement avec le service
Lambda ou de l’utiliser comme un proxy HTTP vers un serveur qui délivre l’API
(via EB dans mon exemple). Sur le schéma, le choix Lambda / DynamoDB est
représenté en pointillés rouges car je ne l’ai pas expérimenté, je l’ai
simplement étudié un peu puis laissé de côté pour me concentrer sur
l’utilisation d’EB avec MongoDB.

La raison à cela vient du fait que pour le moment le service Lambda ne propose
pas d’utiliser facilement un service de BDD basé sur MongoDB car Amazon
propose DynamoDB qui est son service NoSQL. L’autre possibilité serait
d’utiliser une base plus “traditionnelle” tel que MySQL mais on perd entre
autre l’intérêt de la rapidité du NoSQL sur les bases relationnelles. L’autre
point qui fait que je ne me suis pas plus penché dessus vient simplement du
fait que, ne connaissant pas du tout DynamoDB, je ne voulais pas “perdre du
temps” à me former dessus afin d’être capable de sortir rapidement un
prototype fonctionnel. De plus, l’utilisation de Lambda est totalement
différente de ma façon habituelle de coder. En effet, chaque code étant
stateless il faut repenser l’architecture de son projet et avoir en tête ce
mode de fonctionnement assez particulier.

Passons donc à EB. Pour l’utiliser, je suis passé par l’outil en ligne de
commande qu’ils proposent afin de ne pas passer tout le temps par le site pour
déployer son code. Le principe est simple : On code son application puis on la
déploie sur EB. Une fois lancée sur EB elle est accessible via une URL
particulière et peut être utilisée sans problème :
https://mon-api-dev.eu-west-2.elasticbeanstalk.com/

Il est possible de configurer tout un tas de choses sur EB comme pour chacun
des services proposés par Amazon. Ici je me suis contenté de configurer
l’application pour lui dire d’utiliser du HTTPS (désactivé par défaut) et je
l’ai relié à un certificat SSL que j’ai configuré via le service Certificate
Manager. L’interface d’EB donne également accès à l’état de santé de notre
application, à ses logs, etc.

La liaison avec MongoDB se fait directement dans le code de manière
traditionnelle et est vraiment distincte d’EB, ce dernier ne faisant que
office d’hébergeur pour l’application. Le service S3 est également utilisé
directement dans le code afin, dans mon exemple d’application, de stocker les
avatars des utilisateurs. Il pourrait également être utilisé pour stocker les
fichiers de ressource comme les PDF, vidéos, etc. en ayant une notion de droit
d’accès dessus.

## Architecture proposée

![AWS - Schéma architecture proposée](/images/aws-schema-architecture-proposee.png)

Comme on peut le voir, la partie API Gateway a été retirée (et celle de Lambda
aussi évidemment). L’intérêt ici est de retirer une couche qui n’est pas
forcément nécessaire dans notre cas de figure. Toute la partie sécurité que
proposer API Gateway peut être implémentée directement dans l’application (JWT,
OAuth, etc.) et les autres fonctionnalités comme les plans d’usage à l’API
(limitation du nombre d’appels, etc.) ne sont pas nécessaires.

Cela permet de retirer une couche applicative afin de fluidifier la maintenance
de l’API car, je le rappel, tous ces services m’étaient inconnus jusque là et
je ne prétends pas savoir les utiliser après avoir passé du temps à les
utiliser.

On garde toujours l’utilisation de Swagger pour designer l’API cela ne change
pas. Par contre, il n’y a plus de possibilité de synchronisation automatique
car cela concernait API Gateway. Cependant, Swaggerhub est capable de nous
proposer des squelettes prêts à l’emploi pour coder l’API client / serveur en
différents langages (donc NodeJS pour le côté serveur) ce qui fait que l’on
obtient un projet préparé avec l’ensemble des points d’accès etc. et qu’il
reste à coder la partie logique de l’application puis de la déployer sur EB.
La partie base de données est également toujours gérée par mLab et permet
d’utiliser MongoDB sans problème tout comme S3 est toujours présent afin de
stocker les fichiers de l’application comme les avatars.
