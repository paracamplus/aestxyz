-- Quelques modifications a la base initiale pour VMmd

set search_path to fw4ex, public;

\pset pager off

begin;
-- reinitialiser le compteur
alter sequence fw4ex_seq restart with 10000;
-- creer l'utilisateur par defaut:
insert into Person(id, lastname, firstname, email, pseudo, confirmedemail)
values(11, 'FW4EX', 'nobody', 'nobody@nobo.dy', 
       'nobody FW4EX', true);
-- Creer l'exercice 0000 utilise temporairement quand on ne sait pas
-- encore quel est le numero de l'exercice que l'on autoteste.
insert into Exercise(uuid, name, nickname, totalMark, person_id)
values('00000000000000000000000000000000',
       'com.paracamplus.exercise.unknown',
       '?',
       0,
       (select p.id from Person p where p.email = 'nobody@nobo.dy'));
-- creer l'utilisateur representant le MD:
insert into Person(id, lastname, firstname, email, pseudo, confirmedemail)
values(42, 'FW4EX', 'autochecker', 'autochecker@paracamplus.com', 
       'autochecker FW4EX', true);
-- me creer comme l'auteur des exercices pre-charges:
insert into Person(id, lastname, firstname, email, pseudo, confirmedemail)
values(1000, 'Queinnec', 'Christian', 'Christian.Queinnec@fw4ex.org', 
       'QNC', true);
insert into Author (person_id, prefix) values(1000, '');
insert into Author (person_id, prefix) values(42, '');
commit;

-- Nettoyage des tables inutiles
begin;
drop table Accesslink;
drop table Payment;
drop table Accounting;
drop table Account;
delete from Batch;
drop table GivenBadge;
drop table Badge;
drop table Campaign;
delete from Exercise where not valid;
delete from ExerciseAuthor;
delete from ExerciseTag;
delete from Job;
delete from MarkDetail;
delete from MarkEngine;
drop table PersonGroupContent;
drop table PersonGroup;
drop table Score;
drop table Skill;
drop table ExerciseGroupContent;
drop table ExerciseGroup;
commit;

-- Supprimer dependances de Job envers Exercice, Person. Les
-- dependances seront verifiees lors du transfert des donnees vers la
-- base centrale. Cela evite d'avoir a dupliquer la table des
-- exercices et des personnes vers les VMmd ce qui n'est pas
-- maintenable quand ces tables evoluent.
alter table Job
      drop constraint job_exercise_uuid_fkey;
alter table Job
      drop constraint job_person_id_fkey;
alter table Exercise
      drop constraint exercise_person_id_fkey;

-- end.
