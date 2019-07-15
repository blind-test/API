-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
ALTER TABLE questions ADD answers TEXT;

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
ALTER TABLE questions DROP COLUMN answers;
