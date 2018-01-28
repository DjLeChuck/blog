---
title: "Meteor - API REST"
date: 2017-01-20T08:35:28+01:00
authors: ["djlechuck"]
tags: ["api rest", "meteor"]
categories: ["veille-et-tests"]
---

Meteor client et serveur communiquent via un protocole appelé DDP
{{< ref "https://github.com/meteor/meteor/blob/devel/packages/ddp/DDP.md" >}},
qui fonctionne au travers d’une connexion websocket qui est maintenu tout au
long de la navigation du client sur le site.

Généralement, les données sont stockées dans une base MongoDB sur le serveur.
Cette base est gérée par Meteor et a des spécificités propres à Meteor (on ne
peut pas greffer une base Mongo existante de but-en-blanc sans adaptation).

Pour échanger les données entre le serveur et le client, on utilise soit le
système de publication / souscription
{{< ref "https://guide.meteor.com/data-loading.html" >}}, soit le système de
méthodes {{< ref "https://guide.meteor.com/methods.html" >}}.
Dans les deux cas, quand le serveur envoie un jeu de données au client, ce
dernier va les stocker en local dans un genre de base MongoDB entièrement géré
en javascript appelé minimongo
{{< ref "https://github.com/meteor/meteor/blob/master/packages/minimongo/README.md" >}}.
Cette architecture permet aux échanges d’être dynamiques et d’accélérer les
temps de réponse entre les échanges. Quand le serveur met à jour une donnée,
il l’envoie au client qui va l’intégrer dans sa copie des données et travailler
avec. De même, si le client modifie les données qu’il possèdent en local le
serveur est averti afin de faire persister ces changements dans la “vraie”
base MongoDB.

Mais alors, comment cela se passe-t-il quand on doit utiliser autre chose
qu’une base MongoDB côté serveur pour gérer ses données ? Et bien il faut
utiliser l’API de bas niveau du système de publication
{{< ref "https://guide.meteor.com/data-loading.html#custom-publication" >}}.
Cette API bas niveau permet de gérer soit-même le moment où le serveur
indiquera au client “voici une nouvelle donnée”, “cette donnée a été modifiée”
ou encore “cette donnée vient d’être supprimée”. Le client lui ne se rend pas
compte de la différence car le protocole DDP est toujours utilisé pour les
échanges donc il peut continuer à utiliser sa base minimongo pour stocker ses
extraits de données.
Tout cela a l’air merveilleux, mais en fin de chapitre on peut lire ceci :

<blockquote>One point to be aware of is that if you allow the user to modify
data in the “pseudo-collection” you are publishing in this fashion, you’ll want
to be sure to re-publish the modifications to them via the publication, to
achieve an optimistic user experience.</blockquote>

Oups. C’est ce qu’on veut faire nous permettre au client de modifier des
informations, pas plus d’informations que ça dans la doc ? Et bien non, allons
donc demander à notre cher ami Google si il peut nous aider sur ce point.

On tombe très vite sur plusieurs articles qui expliquent comment utiliser
l’API de bas niveau permettant de gérer les données avec une API REST :
[ici](http://meteorcapture.com/publishing-data-from-an-external-api/) ou bien
[là](https://medium.com/meteor-js/how-to-connect-meteor-js-to-an-external-api-93c0d856433b#.6cytwexiw").
Ce sont vraiment de bons articles qui permettent de comprendre le
fonctionnement de cette API de bas niveau et de la mettre en pratique sauf
que, car rien n’est toujours parfait, ils n’expliquent pas comment le client
peut faire remonter ses modifications au serveur. Le seul but ici est de
récupérer des informations depuis le serveur sans jamais le faire dans l’autre
sens.
Les problèmes commencent alors. Comment faire pour que le serveur soit au
courant de ce que fait le client ? Et bien en utilisant le système de méthodes
pardi !

Basiquement, l’utilisation de méthodes est censée être assez simple car une
même méthode peut être utilisée à la fois pour le client et pour le serveur,
mais seulement dans le cas où les deux utilisent des bases MongoDB (ou
minimongo, mais c’est pareil) pour stocker ses données. Or nous, sur le
serveur, on ne veut pas de base MongoDB alors on va devoir faire une méthode
pour le client puis une méthode pour le serveur à chaque fois (le client,
quand il appelle une méthode via Meteor.call, va déclencher à la fois la
méthode spécifique au client et celle spécifique au serveur simplement
parce-qu’elles auront le même nom, pratique).

Admettons que nous voulions nous inscrire ou nous désinscrire à un atelier.
Nos deux méthodes clientes sont extrêmement simples :

```js
Meteor.methods({
    subscription: function (subscription) {
        return SessionSubscriptions.insert(subscription);
    },

    unsubscription: function (subscription) {
        SessionSubscriptions.remove({ _id:subscription._id });
    },
});
```

On se contente d’insérer ou de supprimer un enregistrement sans autre
vérification. Cela permet au client de voir directement son interface
utilisateur changer en conséquence (le bouton **s’inscrire** devient
**se désinscrire** et inversement, c’est le principe d’Optimistic UI
{{< ref "https://blog.meteor.com/optimistic-ui-with-meteor-67b5a78c3fcf" >}}
{{< ref "https://uxplanet.org/optimistic-1000-34d9eefe4c05" >}}.
Côté serveur, il va falloir que nous interrogions nos APIs pour savoir si les
données sont bonnes etc. puis, une fois que c’est validé, faire
l’enregistrement (ou la suppression). Ok, c’est fait, ça fonctionne mon API est
appelée etc. mais comment avertir mon client que j’ai pris en compte sa
demande ? Certes, de son côté il a déjà mis à jour son affichage mais il faut
quand même lui dire si sa requête était bonne ou non et a donné le résultat
escompté.
Pour se faire, et bien il faut retourner aux publications, avec l’API de base
niveau. Très vite on comprend qu’il faut utiliser **this.changed** et
**this.removed** parce-qu’à force de lire la même page de documentation en
boucle ça finit par rentrer.

Hum. Ok on doit utiliser ces 2 méthodes dans la publication, mais comment les
déclencher au bon moment ? Actuellement, notre publication envoie les données
au client et notre méthode récupère les données du client pour les mettre à
jour. Il va donc falloir appeler notre publication à travers notre méthode !
Galère galère de trouver comment faire, alors que c’est tout con finalement.
On garde une référence de notre publication en variable et on l’utilise dans la
méthode tout simplement
{{< ref "http://phucnguyen.info/blog/how-to-publish-to-a-client-only-collection-in-meteor/" >}}.

Et voilà ! Nous avons tout ce qu’il nous faut pour utiliser les APIs et
interagir avec le client sans qu’il ne se rende compte de rien !

Alors, combien de temps pour tout ça ? 3 jours. 3 jours pour réussir à
comprendre comment faire communiquer les API avec Meteor et voir que ce n’est
pas simple (d’ailleurs, il reste toute la partie utilisateurs à greffer aux
API et ce n’est pas simple car la grosse boîte noire actuellement utilisée
doit être revue afin de l’utiliser à un niveau plus bas, style une boîte grise
afin de mieux maîtriser ce qu’il se passe et pouvoir glisser notre API au
milieu des processus d’inscription / connexion).

Meteor avait prévenu pourtant si on lit la documentation sur les méthodes et
plus particulièrement le tout premier point
[What is a method?](https://guide.meteor.com/methods.html#what-is-a-method).
C’est comparé à une API REST mais ce n’est pas une API REST. D’ailleurs, nous
ne sommes pas les seuls à nous en être rendu compte si l’on en croit
[cet article](https://medium.com/unexpected-token/how-to-make-meteor-web-apps-communicate-together-a-comparison-with-the-rest-api-method-acef91040faf)
qui conclu par :

<blockquote>As we’ve seen, Meteor doesn’t use REST API (even if it’s really
easy to create your own REST API) because it doesn’t support the real-time nor
the websockets needed by modern applications. It defines a new simple open
protocol called DDP. Today, more and more wrappers exist in different languages
to handle DDP.</blockquote>
