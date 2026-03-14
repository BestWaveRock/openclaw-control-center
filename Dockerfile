# 1. -------------- 编译阶段 --------------
FROM node:22-alpine AS builder

# 安装pnpm（如用npm/yarn可删）
RUN npm i -g pnpm

WORKDIR /app
# 先拷贝包管理文件，利用缓存
COPY package.json ./  
RUN pnpm install

# 再拷贝源码 & 构建
COPY . .
RUN pnpm run build      # 默认输出 dist/ 目录


# 2. -------------- 运行阶段 --------------
RUN npm run smoke:ui
RUN UI_MODE=true npm run dev

# 把构建产物放到 nginx 默认 html 目录
# COPY --from=builder /app/dist /usr/share/nginx/html

# 可选：用自己写的 nginx.conf
# COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 4310
