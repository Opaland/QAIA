// Suite generee depuis `testbook/json-server-rest.feature`, lui-meme ecrit depuis le seul
// README.md de `typicode/json-server` au commit 8fb0f72 (2024-05-13).
//
// Cette suite est destinee a etre executee DEUX FOIS, contre deux versions du meme logiciel :
// la version de mai 2024 et la version courante. Un test qui echoue sur l'une et passe sur
// l'autre designe un defaut reel, corrige depuis, que ce cahier aurait attrape le jour ou il
// est parti en production. C'est la seule mesure d'utilite disponible sans un humain.
//
// Regle tenue : aucun commit de correction, aucun ticket, aucun test du projet cible n'a ete lu
// avant l'ecriture de ce fichier. Les seuls elements connus a l'avance sont les *titres* des
// commits de correction (donc les zones concernees), jamais leur contenu -- limite declaree
// dans le rapport, pas minimisee.
//
// Isolation : tout test qui ecrit cree sa propre ressource et n'en touche aucune autre. Les
// deux executions partent d'une base identique, mais aucun test ne depend de l'ordre.
const { test, expect } = require('@playwright/test');

const BASE = process.env.SUT_URL || 'http://localhost:3010';

// Q3 du cahier : la forme de la reponse paginee n'est documentee NULLE PART. Assertir un tableau
// nu serait inventer l'exigence ; assertir une enveloppe aussi. Ce helper extrait les elements
// quelle que soit la forme, et les scenarios n'assertent que leur nombre et leur identite.
function itemsOf(body) {
  if (Array.isArray(body)) return body;
  if (body && Array.isArray(body.data)) return body.data;
  if (body && Array.isArray(body.items)) return body.items;
  return null;
}

async function ids(request, url) {
  const r = await request.get(BASE + url);
  const items = itemsOf(await r.json());
  return items === null ? null : items.map((x) => String(x.id));
}

// --- Routes de collection et d'element ---------------------------------------------------

test('@QAIA-EXT-001 la collection entiere est renvoyee', async ({ request }) => {
  expect(await ids(request, '/posts')).toEqual(['1', '2']);
});

test('@QAIA-EXT-002 un element est renvoye par son identifiant', async ({ request }) => {
  const r = await request.get(BASE + '/posts/1');
  const body = await r.json();
  expect(body.id).toBe('1');
  expect(body.title).toBe('a title');
});

test('@QAIA-EXT-003 un identifiant inexistant ne renvoie pas de ressource', async ({ request }) => {
  // open: Q4 -- aucun code de statut n'est documente. L'assertion porte sur ce que le README
  // promet reellement : il n'existe pas de post 999, donc la reponse ne peut pas en contenir un.
  const r = await request.get(BASE + '/posts/999');
  const text = await r.text();
  let body = null;
  try { body = JSON.parse(text); } catch (e) { body = null; }
  expect(body === null || body.id !== '999').toBe(true);
  expect(r.ok()).toBe(false); // une ressource absente ne peut pas etre un succes
});

test('@QAIA-EXT-004 une collection inexistante ne renvoie aucune ressource', async ({ request }) => {
  const r = await request.get(BASE + '/inexistant');
  expect(r.ok()).toBe(false);
});

test('@QAIA-EXT-005 l objet singulier profile est lisible', async ({ request }) => {
  const r = await request.get(BASE + '/profile');
  expect((await r.json()).name).toBe('typicode');
});

// --- Ecriture ------------------------------------------------------------------------------

test('@QAIA-EXT-006 un identifiant est genere quand il manque', async ({ request }) => {
  // README, "Notable differences with v0.17" : « id is always a string and will be generated
  // for you if missing ». Deux promesses distinctes, assertees separement.
  const r = await request.post(BASE + '/posts', { data: { title: 'sans id', views: 1 } });
  const body = await r.json();
  expect(body.id).toBeTruthy();
  expect(typeof body.id).toBe('string');
  await request.delete(BASE + '/posts/' + body.id);
});

test('@QAIA-EXT-007 l identifiant est toujours une chaine', async ({ request }) => {
  const r = await request.get(BASE + '/posts');
  const items = itemsOf(await r.json());
  expect(items.length).toBeGreaterThan(0);
  for (const p of items) expect(typeof p.id).toBe('string');
});

test('@QAIA-EXT-008 PUT remplace la ressource', async ({ request }) => {
  const created = await (await request.post(BASE + '/posts', { data: { title: 'avant', views: 7 } })).json();
  await request.put(BASE + '/posts/' + created.id, { data: { title: 'remplace' } });
  const after = await (await request.get(BASE + '/posts/' + created.id)).json();
  expect(after.title).toBe('remplace');
  await request.delete(BASE + '/posts/' + created.id);
});

test('@QAIA-EXT-009 PATCH modifie un champ et conserve les autres', async ({ request }) => {
  const created = await (await request.post(BASE + '/posts', { data: { title: 'avant', views: 42 } })).json();
  await request.patch(BASE + '/posts/' + created.id, { data: { title: 'patche' } });
  const after = await (await request.get(BASE + '/posts/' + created.id)).json();
  expect(after.title).toBe('patche');
  expect(after.views).toBe(42); // le champ non touche doit survivre : c'est tout l'objet de PATCH
  await request.delete(BASE + '/posts/' + created.id);
});

test('@QAIA-EXT-010 DELETE retire la ressource', async ({ request }) => {
  const created = await (await request.post(BASE + '/posts', { data: { title: 'a supprimer' } })).json();
  await request.delete(BASE + '/posts/' + created.id);
  const list = await ids(request, '/posts');
  expect(list).not.toContain(String(created.id));
});

test('@QAIA-EXT-011 PATCH sur l objet singulier profile', async ({ request }) => {
  await request.patch(BASE + '/profile', { data: { name: 'modifie' } });
  const after = await (await request.get(BASE + '/profile')).json();
  expect(after.name).toBe('modifie');
  await request.patch(BASE + '/profile', { data: { name: 'typicode' } });
});

// --- Conditions ------------------------------------------------------------------------------

test('@QAIA-EXT-012 egalite implicite sur un champ', async ({ request }) => {
  expect(await ids(request, '/posts?views=200')).toEqual(['2']);
});

test('@QAIA-EXT-013 superieur strict', async ({ request }) => {
  expect(await ids(request, '/posts?views_gt=100')).toEqual(['2']);
});

test('@QAIA-EXT-014 superieur strict exclut la valeur exacte', async ({ request }) => {
  expect(await ids(request, '/posts?views_gt=200')).toEqual([]);
});

test('@QAIA-EXT-015 superieur ou egal inclut la valeur exacte', async ({ request }) => {
  expect(await ids(request, '/posts?views_gte=200')).toEqual(['2']);
});

test('@QAIA-EXT-016 inferieur strict', async ({ request }) => {
  expect(await ids(request, '/posts?views_lt=200')).toEqual(['1']);
});

test('@QAIA-EXT-017 inferieur ou egal inclut la valeur exacte', async ({ request }) => {
  expect(await ids(request, '/posts?views_lte=100')).toEqual(['1']);
});

test('@QAIA-EXT-018 different exclut la valeur donnee', async ({ request }) => {
  expect(await ids(request, '/posts?views_ne=100')).toEqual(['2']);
});

test('@QAIA-EXT-019 deux conditions sur le meme champ se combinent', async ({ request }) => {
  expect(await ids(request, '/posts?views_gt=100&views_lt=300')).toEqual(['2']);
});

test('@QAIA-EXT-020 une condition sur un champ absent ne renvoie rien', async ({ request }) => {
  expect(await ids(request, '/posts?champ_absent=valeur')).toEqual([]);
});

// --- Plage -------------------------------------------------------------------------------------

test('@QAIA-EXT-021 _limit borne le nombre d elements', async ({ request }) => {
  expect(await ids(request, '/posts?_limit=1')).toEqual(['1']);
});

test('@QAIA-EXT-022 _start decale le debut', async ({ request }) => {
  expect(await ids(request, '/posts?_start=1')).toEqual(['2']);
});

test('@QAIA-EXT-023 _start et _end delimitent une tranche', async ({ request }) => {
  expect(await ids(request, '/posts?_start=0&_end=1')).toEqual(['1']);
});

// --- Pagination --------------------------------------------------------------------------------

test('@QAIA-EXT-024 une page de taille 1 ne contient qu un element', async ({ request }) => {
  const list = await ids(request, '/posts?_page=1&_per_page=1');
  expect(list).not.toBeNull(); // open: Q3 -- une forme que ce helper ne sait pas lire est un echec franc
  expect(list).toEqual(['1']);
});

test('@QAIA-EXT-025 la deuxieme page contient l element suivant', async ({ request }) => {
  const list = await ids(request, '/posts?_page=2&_per_page=1');
  expect(list).not.toBeNull();
  expect(list).toEqual(['2']);
});

// --- Tri ----------------------------------------------------------------------------------------

test('@QAIA-EXT-026 tri ascendant sur un champ numerique', async ({ request }) => {
  expect(await ids(request, '/posts?_sort=views')).toEqual(['1', '2']);
});

test('@QAIA-EXT-027 le prefixe moins inverse le tri', async ({ request }) => {
  expect(await ids(request, '/posts?_sort=-views')).toEqual(['2', '1']);
});

// --- Embed ----------------------------------------------------------------------------------------

test('@QAIA-EXT-028 un post embarque ses commentaires', async ({ request }) => {
  const items = itemsOf(await (await request.get(BASE + '/posts?_embed=comments')).json());
  const post1 = items.find((p) => String(p.id) === '1');
  expect(Array.isArray(post1.comments)).toBe(true);
  expect(post1.comments.map((c) => String(c.id)).sort()).toEqual(['1', '2']);
});

test('@QAIA-EXT-029 un commentaire embarque son post', async ({ request }) => {
  // open: Q6 -- la regle de nommage pluriel/singulier n'est pas enoncee, seul l'exemple l'est.
  const items = itemsOf(await (await request.get(BASE + '/comments?_embed=post')).json());
  for (const c of items) {
    expect(c.post, 'commentaire ' + c.id).toBeTruthy();
    expect(String(c.post.id)).toBe('1');
  }
});

// --- Suppression en cascade -------------------------------------------------------------------------

test('@QAIA-EXT-030 _dependent supprime les ressources dependantes', async ({ request }) => {
  const post = await (await request.post(BASE + '/posts', { data: { title: 'parent' } })).json();
  const c1 = await (await request.post(BASE + '/comments', { data: { text: 'x', postId: String(post.id) } })).json();
  await request.delete(BASE + '/posts/' + post.id + '?_dependent=comments');
  const restants = await ids(request, '/comments');
  expect(restants).not.toContain(String(c1.id));
});

// --- Champs imbriques ----------------------------------------------------------------------------------

test('@QAIA-EXT-031 filtrer sur un champ imbrique', async ({ request }) => {
  expect(await ids(request, '/foo?a.b=bar')).toEqual(['1']);
});

test('@QAIA-EXT-032 filtrer sur un element de tableau par son indice', async ({ request }) => {
  expect(await ids(request, '/foo?arr[0]=bar')).toEqual(['1']);
});
