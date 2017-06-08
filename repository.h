#ifndef REPOSITORY_H
#define REPOSITORY_H

struct repository {
	/* Environment */
	char *gitdir;
	char *commondir;
	char *objectdir;
	char *index_file;
	char *graft_file;
	char *namespace;
	char *worktree;

	/* Configurations */
	unsigned ignore_env:1;
	/* Indicates if a repository has a different 'commondir' from 'gitdir' */
	unsigned different_commondir:1;
};

extern struct repository *the_repository;

extern void repo_set_gitdir(struct repository *repo, const char *path);
extern void repo_set_worktree(struct repository *repo, const char *path);
extern char *repo_worktree_path(struct repository *repo, const char *path);
extern int repo_init(struct repository *repo, const char *path);
extern void repo_clear(struct repository *repo);

#endif /* REPOSITORY_H */
