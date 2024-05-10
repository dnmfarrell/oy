drop table if exists task;
create table task (
  task_id integer not null,
  set_name varchar(255) not null,
  set_value varchar(255) not null,
  cargo text,
  t timestamp default (datetime('now'))
);
drop index if exists idx_task;
create index idx_task on task (
  task_id,
  set_name,
  set_value,
  cargo,
  t
);
