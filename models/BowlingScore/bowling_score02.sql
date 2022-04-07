
CREATE TABLE players (
       "player_id" INTEGER NOT NULL,
       "username" TEXT NOT NULL DEFAULT '',
       "password" TEXT NOT NULL DEFAULT '',
       "player_name" TEXT NOT NULL,
       "admin" INTEGER NOT NULL,
       PRIMARY KEY("player_id")
       );

CREATE TABLE score_sheets (
       "score_sheet_id" INTEGER NOT NULL,
       "play_date" TIMESTAMP NOT NULL DEFAULT 'datetime(CURRENT_TIMESTAMP,''localtime'')',
       PRIMARY KEY("score_sheet_id" AUTOINCREMENT)
       );

CREATE TABLE games (
       "game_id" INTEGER NOT NULL,
       "score_sheet_id" INTEGER NOT NULL DEFAULT 0,
       PRIMARY KEY("game_id" AUTOINCREMENT),
       FOREIGN KEY("score_sheet_id") REFERENCES score_sheets("score_sheet_id")
       );

CREATE TABLE scores (
       "score_id" INTEGER NOT NULL DEFAULT 1,
       "player_id" INTEGER NOT NULL DEFAULT 0,
       "game_id" INTEGER,
       PRIMARY KEY("score_id" AUTOINCREMENT),
       FOREIGN KEY("game_id") REFERENCES games("game_id"),
       FOREIGN KEY("player_id") REFERENCES players("player_id")
       );

CREATE TABLE frames (
       "frame_id" INTEGER NOT NULL,
       "score_id" INTEGER NOT NULL DEFAULT 0,
       "frame_no" INTEGER NOT NULL DEFAULT 1,
       "first" INTEGER NOT NULL DEFAULT 0,
       "second" INTEGER NOT NULL DEFAULT 0,
       "spare_bonus" INTEGER NOT NULL DEFAULT 0,
       "strike_bonus" INTEGER NOT NULL DEFAULT 0,
       "frame_total" INTEGER NOT NULL DEFAULT 0,
       PRIMARY KEY("frame_id" AUTOINCREMENT),
       FOREIGN KEY("score_id") REFERENCES scores("score_id")
       );

