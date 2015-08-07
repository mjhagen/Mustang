INSERT INTO "public"."logaction"    ( id, name, "class" ) VALUES ( '163e8056-0fd7-4e7d-a9ab-c8b6010fdf8b', 'created',  'success' );
INSERT INTO "public"."logaction"    ( id, name, "class" ) VALUES ( '1e170597-7890-425f-ac31-b5c60285989c', 'changed',  'default' );
INSERT INTO "public"."logaction"    ( id, name, "class" ) VALUES ( '249b01ed-d0ba-4cbc-ade5-a29b5e2d649f', 'restored', 'warning' );
INSERT INTO "public"."logaction"    ( id, name, "class" ) VALUES ( '469acd91-0cc4-42ee-805b-0cacbac6a851', 'removed',  'danger' );
INSERT INTO "public"."logaction"    ( id, name, "class" ) VALUES ( '5c9dae17-a7d9-8288-1968-0b8b4c6c278f', 'security', 'default text-muted' );
INSERT INTO "public"."logaction"    ( id, name, "class" ) VALUES ( 'c4d5177f-23ca-48bd-89f8-2f85eccb5699', 'init',     'info' );
INSERT INTO "public"."logaction"    ( id, name, "class" ) VALUES ( 'c67bb518-600a-42fa-8445-ae815778b4b7', 'saved',    'success' );

INSERT INTO "public"."securityrole" ( id, deleted, name, loginscript ) VALUES ( 'a4163666-f3b0-0d48-7aae-765738a65c61', 'f', 'Administrator', 'admin:main.default' );

INSERT INTO "public"."logged"       ( id, entityname, deleted, securityroleid ) VALUES ( 'a431d806-a624-c136-f78b-c68760f8e989', 'contact', 'f', 'a4163666-f3b0-0d48-7aae-765738a65c61' );
INSERT INTO "public"."contact"      ( id, username, password, firstname, lastname, email, securityroleid ) VALUES ( 'a431d806-a624-c136-f78b-c68760f8e989', 'admin', '41CC4E75799C0D087289C0C67394F490B976D58807BBB66ABE6D1B02201FB365080EC23B06071606A65E643E211D615D72D504AD4D9695A9167A873AFD94CA25tFxzF4R46jqUT6YE', 'Mingo', 'Hagen', 'email@mingo.nl', 'a4163666-f3b0-0d48-7aae-765738a65c61' );

INSERT INTO "public"."option"       ( id, deleted, type, name, code ) VALUES ( '767f71b3-a78b-a302-5cba-587f2524c0d8', 'f', 'language', 'English', 'en' );
INSERT INTO "public"."option"       ( id, deleted, type, name, code ) VALUES ( 'b4083d4d-e789-b82e-edf9-f6572e4d545f', 'f', 'country', 'United States', 'US' );
INSERT INTO "public"."option"       ( id, deleted, type, name ) VALUES ( '4b147606-ac1f-45d6-9d88-09596ba73cc3', 'f', 'method', 'Blasting' );
INSERT INTO "public"."option"       ( id, deleted, type, name ) VALUES ( 'b3d661b7-7f14-4bb2-807b-98b7a2e7a699', 'f', 'method', 'Heavy sweep' );
INSERT INTO "public"."option"       ( id, deleted, type, name ) VALUES ( '69c3f2ef-e66e-417f-8c23-2778fec6b53b', 'f', 'method', 'HPFW' );
INSERT INTO "public"."option"       ( id, deleted, type, name ) VALUES ( 'dded1cb9-d575-4b3f-b98d-1dc5afd5d01a', 'f', 'method', 'Hydrojetting' );
INSERT INTO "public"."option"       ( id, deleted, type, name ) VALUES ( '8e4f0615-597e-4522-a53b-7965e4b62737', 'f', 'method', 'Light sweep' );
INSERT INTO "public"."option"       ( id, deleted, type, name ) VALUES ( '5c78a306-df8b-4403-8c60-169c9eef46f9', 'f', 'method', 'Power tool' );
INSERT INTO "public"."option"       ( id, deleted, type, name ) VALUES ( '9e885c96-cfb8-4c8e-acb9-0769462ffaa3', 'f', 'method', 'Wet/slurry blast' );

INSERT INTO "public"."locale"       ( id, languageid, countryid ) VALUES ( 'b561bea9-d004-968f-0661-b5f6b4ff2acb', '767f71b3-a78b-a302-5cba-587f2524c0d8', 'b4083d4d-e789-b82e-edf9-f6572e4d545f' );
