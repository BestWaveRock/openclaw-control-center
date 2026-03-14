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
FROM node:22-alpine AS runner
WORKDIR /app

# 只需要从编译阶段拷贝构建后的文件和依赖
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/.env ./
COPY --from=builder /app/package.json ./
COPY --from=builder /app/node_modules ./node_modules

EXPOSE 4310

# 使用 node 运行你的入口文件
CMD ["node", "dist/index.js"]
