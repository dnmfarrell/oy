drop table if exists task_tag;
create table task_tag (
  key integer primary key autoincrement,
  txt varchar(255) not null,
  t timestamp default (datetime('now')),
  cargo varchar(255),
  task_key integer not null,
  set_name integer not null
);
drop index if exists idx_task_set;
create index idx_task_set on task_tag (task_key, set_name);
