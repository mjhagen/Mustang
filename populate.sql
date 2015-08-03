-- INSERT INTO "public"."logaction" ( id, name, "class" ) VALUES ( '163e8056-0fd7-4e7d-a9ab-c8b6010fdf8b', 'created',  'success' );
-- INSERT INTO "public"."logaction" ( id, name, "class" ) VALUES ( '1e170597-7890-425f-ac31-b5c60285989c', 'changed',  'default' );
-- INSERT INTO "public"."logaction" ( id, name, "class" ) VALUES ( '249b01ed-d0ba-4cbc-ade5-a29b5e2d649f', 'restored', 'warning' );
-- INSERT INTO "public"."logaction" ( id, name, "class" ) VALUES ( '469acd91-0cc4-42ee-805b-0cacbac6a851', 'removed',  'danger' );
-- INSERT INTO "public"."logaction" ( id, name, "class" ) VALUES ( '5c9dae17-a7d9-8288-1968-0b8b4c6c278f', 'security', 'default text-muted' );
-- INSERT INTO "public"."logaction" ( id, name, "class" ) VALUES ( 'c4d5177f-23ca-48bd-89f8-2f85eccb5699', 'init',     'info' );
-- INSERT INTO "public"."logaction" ( id, name, "class" ) VALUES ( 'c67bb518-600a-42fa-8445-ae815778b4b7', 'saved',    'success' );

INSERT INTO "public"."language" ( id, deleted, name, code ) VALUES ( '767f71b3-a78b-a302-5cba-587f2524c0d8', 'f', 'English', 'en_US' );

INSERT INTO "public"."securityrole" ( id, deleted, name, loginscript ) VALUES ( 'a4163666-f3b0-0d48-7aae-765738a65c61', 'f', 'Administrator', 'admin:main.default' );

-- INSERT INTO "public"."logged" ( id, entityname, deleted, securityroleid ) VALUES ( 'a431d806-a624-c136-f78b-c68760f8e989', 'contact', 'f', 'a4163666-f3b0-0d48-7aae-765738a65c61' );
INSERT INTO "public"."contact" ( id, deleted, username, password, firstname, lastname, email, securityroleid ) VALUES (
  'a431d806-a624-c136-f78b-c68760f8e989',
  'f',
  'admin',
  '41CC4E75799C0D087289C0C67394F490B976D58807BBB66ABE6D1B02201FB365080EC23B06071606A65E643E211D615D72D504AD4D9695A9167A873AFD94CA25tFxzF4R46jqUT6YE',
  'Mingo',
  'Hagen',
  'email@mingo.nl',
  'a4163666-f3b0-0d48-7aae-765738a65c61'
);
