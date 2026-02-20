-- SPDX-License-Identifier: CC-BY-NC-4.0
INSERT INTO languages (code, name)
VALUES
  ('EN', 'English'),
  ('JP', 'Japanese')
ON CONFLICT (code) DO NOTHING;

INSERT INTO card_conditions (code, name, sort_order)
VALUES
  ('NM', 'Near Mint', 1),
  ('LP', 'Lightly Played', 2),
  ('MP', 'Moderately Played', 3)
ON CONFLICT (code) DO NOTHING;
