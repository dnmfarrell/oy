drop table if exists tag;
create table tag (
  key integer primary key autoincrement,
  grp varchar(255) not null,
  txt varchar(255) not null,
  unique (grp, txt)
);
insert into tag (grp, txt) values
('status', 'new'),
('status', 'done');

drop table if exists task;
create table task (
  key integer primary key autoincrement,
  txt varchar(255) not null
);

drop table if exists task_tag;
create table task_tag (
  task_key integer not null,
  tag_key integer not null,
  t timestamp default (datetime('now')),
  primary key (task_key, tag_key)
);
