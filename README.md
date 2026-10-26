# INFRASTRUCTURES-0
Suite de programme de logiciels de gestion d'infrastructures et d'établissements en Pascal (Turbo Pascal/Free Pascal).

<h2>Liste des fichiers</h2>

Voici la liste des différents fichiers proposés dans INFRASTRUCTURES-0 :

<table>
		<tr>
			<th>Nom</th>
			<th>Description</th>	
		</tr>
	<tr>
		<td><b>AIRPORT.PAS</b></td>
		<td>Cette commande permet de lancer l'application gestion d'aeroports (Airport Management System).</td>
	</tr>
	<tr>
		<td><b>MALL.PAS</b></td>
		<td>Cette commande permet de lancer l'application gestion de centre commercial (Mall Management System).</td>
	</tr>
	<tr>
      <td><b>PARKING.PAS</b></td>
      <td>Cette commande permet de lancer l'application gestion de stationnement de voiture (Parking Management System).</td>
    </tr>
	<tr>
		<td><b>PMS.PAS</b></td>
		<td>Cette commande permet de lancer l'application gestion hoteliere (Property Management System).</td>
	</tr>
	<tr>
		<td><b>TIGRE.PAS</b></td>
		<td>Cette commande permet de lancer l'application gestion du reseau des egouts (Traitement Informatise de la Gestion du Reseau des Egouts).</td>
	</tr>
</table>    

<h2>Remarque</h2>

<ul>
	<li>Le programme MALL.PAS fait des accès directe à des fichiers de base de données de format MySQL.</li>
	<li>Le programme TIGRE.PAS lit et écrit des plans d'égouts au format texte <code>.TGR</code>. Des exemples (Paris, Montréal et Londres) se trouvent dans le dossier <code>SAMPLES/TIGRE</code>. Ces données sont fictives et illustratives. Si aucun plan n'est trouvé, un petit réseau de démonstration est généré.</li>
</ul>

<h2>Utilisation de TIGRE</h2>

<pre><b>TIGRE</b> [<i>FICHIER.TGR</i> | PARIS | MONTREAL | LONDON]</pre>

<ul>
	<li>Clic gauche : outil actif (sélection, déplacement, zoom fenêtre, mesure, ajout de regard ou de tronçon), double-clic : propriétés de l'ouvrage.</li>
	<li>Clic droit + glisser : déplace la carte. Flèches, +/-, Home : navigation et zoom.</li>
	<li>Panneau de droite : sections de couches (A = affichée, R = repérable, T = texte), sélection spatiale, logique et spécifique, macros.</li>
	<li>F2 : rechercher un ouvrage, F3 : rechercher une voie, F6 : liste des établissements (CARINE), F7/F8 : tracé aval/amont, F9 : statistiques.</li>
	<li>Menu Analyse : capacité hydraulique (formule de Manning), pluie de projet, pentes anormales, connectivité du réseau.</li>
</ul>

<h2>Format des plans TIGRE (.TGR)</h2>

Fichier texte dont chaque ligne est composée de champs séparés par des points-virgules :

<table>
	<tr><th>Ligne</th><th>Description</th></tr>
	<tr><td><code>TIGRE;1;titre</code></td><td>En-tête du plan.</td></tr>
	<tr><td><code>O;organisme</code>, <code>A;n;secteur</code></td><td>Organisme et secteurs (arrondissements, quartiers).</td></tr>
	<tr><td><code>N;id;x;y;cote;radier;type;secteur;année;état;débit;bassin;nom</code></td><td>Regard ou ouvrage spécial (regard, vanne, bassin, pompage, déversoir, exutoire).</td></tr>
	<tr><td><code>P;id;amont;aval;hauteur;largeur;forme;matériau;classe;année;état;visitable;voie</code></td><td>Tronçon orienté de l'amont vers l'aval.</td></tr>
	<tr><td><code>S;type;largeur;nom;n</code> puis <code>Q;x;y</code></td><td>Fond de plan : voie, fleuve ou parc.</td></tr>
	<tr><td><code>E;nom;SAP;NAF;commune;code postal;regard;rejet;0</code></td><td>Établissement (CARINE).</td></tr>
	<tr><td><code>V;...</code>, <code>I;...</code></td><td>Événements et interventions.</td></tr>
</table>

<h2>Compilation</h2>
	
Les fichiers Pascal n'ont aucune dépendances, il suffit de télécharger le fichier désiré et de le compiler avec Free Pascal avec la syntaxe de commande  :

<pre><b>fpc</b> <i>LEFICHIER.PAS</i></pre>
	
Sinon, vous pouvez également le compiler avec le Turbo Pascal à l'aide de la syntaxe de commande suivante :	

<pre><b>tpc</b> <i>LEFICHIER.PAS</i></pre>
	
Par exemple, si vous voulez compiler PARKING.PAS, vous devrez tapez la commande suivante :

<pre><b>fpc</b> PARKING.PAS</pre>

<h2>Licence</h2>
<ul>
 <li>Le code source est publié sous la licence <a href="https://github.com/gladir/INFRASTRUCTURES-0/blob/main/LICENSE">MIT</a>.</li>
 <li>Le paquet original est publié sous la licence <a href="https://github.com/gladir/INFRASTRUCTURES-0/blob/main/LICENSE">MIT</a>.</li>
</ul>
