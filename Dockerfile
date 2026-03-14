FROM node:22-alpine AS builder

WORKDIR /app

# 1. 使用官方 pnpm (避免 npm 干扰)
RUN npm config set registry https://registry.npmjs.org \
    && npm install -g pnpm

# 2. 先拷贝包管理文件，利用缓存
COPY package*.json ./

# 3. 安装依赖（使用 --prod 减小体积）
RUN pnpm install --prod && \
    rm -rf /root/.npm

# 4. 清理缓存
RUN pnpm cache clean

# 5. 再拷贝源码 & 构建
COPY . .

# --- 编译阶段结束 ---

FROM node:22-alpine AS runner

WORKDIR /app

# 使用非 root 用户
# USER appuser

# 从编译阶段拷贝构建后的文件和依赖
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/scripts ./scripts
COPY --from=builder /app/.env ./
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/node_modules ./node_modules

# 清理缓存
RUN rm -rf /root/.npm /tmp/*

# 7. 使用环境变量
ENV NODE_ENV=production
ENV GATEWAY_URL=ws://192.168.2.188:18789
ENV PORT=4310

# 8. 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD node -e "require('http').get('http://localhost:4310/health', r => process.exit(r.statusCode === 200 ? 0 : 1))" || exit 1

# 9. 暴露端口
EXPOSE ${PORT}

# 10. 防止容器意外退出（守护进程模式）
CMD ["node", "scripts/ui-smoke.js"]

# 11. 日志驱动配置（可选，需要 docker run 时指定）
# --log-driver json-file
# --log-opt max-size=10m
# --log-opt max-file=5

# 12. 容器重启策略（可选）
