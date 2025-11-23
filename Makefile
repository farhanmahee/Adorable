.PHONY: dev build down migrate seed test lint

dev:
	docker-compose up --build

down:
	docker-compose down --volumes --remove-orphans

migrate:
	cd backend && npx prisma migrate dev --name init

seed:
	cd backend && node prisma/seed.js

test:
	cd backend && npm test

lint:
	cd backend && npm run lint
	cd frontend && npm run lint
	cd mobile && npm run lint
	cd docs && npm run lint
	cd infra && npm run lint
	cd shared && npm run lint
	cd scripts && npm run lint
	cd website && npm run lint
	cd design-system && npm run lint
	cd design-tokens && npm run lint
	cd design-templates && npm run lint
	cd design-guidelines && npm run lint
	cd design-resources && npm run lint
	cd design-assets && npm run lint
	cd design-plugins && npm run lint
	cd design-extensions && npm run lint
	cd design-themes && npm run lint
	cd design-widgets && npm run lint
	cd design-components && npm run lint
	cd design-layouts && npm run lint
	cd design-patterns && npm run lint
	cd design-systems && npm run lint
	cd design-utilities && npm run lint
	cd design-helpers && npm run lint
	cd design-tools && npm run lint
	cd design-libraries && npm run lint
	cd design-modules && npm run lint
	cd design-packages && npm run lint
	cd design-resources && npm run lint
	cd design-assets && npm run lint
	cd design-plugins && npm run lint
	cd design-extensions && npm run lint
	cd design-themes && npm run lint
	cd design-widgets && npm run lint
	cd design-components && npm run lint
	cd design-layouts && npm run lint
	cd design-patterns && npm run lint
	cd design-systems && npm run lint
	cd design-utilities && npm run lint
	cd design-helpers && npm run lint
	cd design-tools && npm run lint
	cd design-libraries && npm run lint
	cd design-modules && npm run lint
	cd design-packages && npm run lint
	cd design-resources && npm run lint
	cd design-assets && npm run lint
	cd design-plugins && npm run lint
	cd design-extensions && npm run lint
	cd design-themes && npm run lint
	cd design-widgets && npm run lint
	cd design-components && npm run lint
	cd design-layouts && npm run lint
	cd design-patterns && npm run lint
	cd design-systems && npm run lint
	cd design-utilities && npm run lint
	cd design-helpers && npm run lint
	cd design-tools && npm run lint
	cd design-libraries && npm run lint
	cd design-modules && npm run lint