-- See https://github.com/PretendoNetwork/friends/pull/15
ALTER TABLE "3ds".user_data
ADD IF NOT EXISTS country integer DEFAULT 0,
ALTER COLUMN comment SET DEFAULT '',
ALTER COLUMN comment_changed SET DEFAULT 0,
ALTER COLUMN last_online SET DEFAULT 0,
ALTER COLUMN favorite_title SET DEFAULT 0,
ALTER COLUMN favorite_title_version SET DEFAULT 0,
ALTER COLUMN mii_name SET DEFAULT '',
ALTER COLUMN mii_data SET DEFAULT '',
ALTER COLUMN mii_changed SET DEFAULT 0,
ALTER COLUMN region SET DEFAULT 0,
ALTER COLUMN area SET DEFAULT 0,
ALTER COLUMN language SET DEFAULT 0;

UPDATE "3ds".user_data SET comment = '' WHERE comment IS NULL;
UPDATE "3ds".user_data SET comment_changed = 0 WHERE comment_changed IS NULL;
UPDATE "3ds".user_data SET last_online = 0 WHERE last_online IS NULL;
UPDATE "3ds".user_data SET favorite_title = 0 WHERE favorite_title IS NULL;
UPDATE "3ds".user_data SET favorite_title_version = 0 WHERE favorite_title_version IS NULL;
UPDATE "3ds".user_data SET mii_name = '' WHERE mii_name IS NULL;
UPDATE "3ds".user_data SET mii_data = '' WHERE mii_data IS NULL;
UPDATE "3ds".user_data SET mii_changed = 0 WHERE mii_changed IS NULL;
UPDATE "3ds".user_data SET region = 0 WHERE region IS NULL;
UPDATE "3ds".user_data SET area = 0 WHERE area IS NULL;
UPDATE "3ds".user_data SET language = 0 WHERE language IS NULL;

ALTER TABLE wiiu.user_data
ALTER COLUMN last_online SET DEFAULT 0;

UPDATE wiiu.user_data SET last_online = 0 WHERE last_online IS NULL;

-- See https://github.com/PretendoNetwork/friends/pull/19
ALTER TABLE "3ds".user_data
ADD IF NOT EXISTS mii_profanity boolean DEFAULT FALSE,
ADD IF NOT EXISTS mii_character_set integer DEFAULT 0;

UPDATE "3ds".user_data SET mii_profanity = FALSE WHERE mii_profanity IS NULL;
UPDATE "3ds".user_data SET mii_character_set = 0 WHERE mii_character_set IS NULL;
