FROM node:22-alpine AS runner

WORKDIR /app

COPY . ./
RUN npm install
RUN npm run build

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
RUN npm -v
RUN npm run dev

