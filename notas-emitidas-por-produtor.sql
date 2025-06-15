select 
  p.id, p.legalName, p.cpfCnpj, p.stateRegistration, p.nfpeNumber,
  (select COUNT(*) from Nfpe as n where n.issuedById = p.id and n.status = 'SENT' and DATE(n.issuedOn) > '2023-01-01' and DATE(n.issuedOn) < '2023-07-01') as '2023 S1',
  (select COUNT(*) from Nfpe as n where n.issuedById = p.id and n.status = 'SENT' and DATE(n.issuedOn) > '2023-06-30' and DATE(n.issuedOn) < '2024-01-01') as '2023 S2',
  (select COUNT(*) from Nfpe as n where n.issuedById = p.id and n.status = 'CANCELLED' and DATE(n.issuedOn) > '2023-01-01' and DATE(n.issuedOn) < '2024-01-01') as 'Canceladas 2023',
  (select COUNT(*) from Nfpe as n where n.issuedById = p.id and n.status = 'SENT' and DATE(n.issuedOn) > '2024-01-01' and DATE(n.issuedOn) < '2024-07-01') as '2024 S1',
  (select COUNT(*) from Nfpe as n where n.issuedById = p.id and n.status = 'SENT' and DATE(n.issuedOn) > '2024-06-30' and DATE(n.issuedOn) < '2025-01-01') as '2024 S2',
  (select COUNT(*) from Nfpe as n where n.issuedById = p.id and n.status = 'CANCELLED' and DATE(n.issuedOn) > '2023-12-31' and DATE(n.issuedOn) < '2025-01-01') as 'Canceladas 2024',
  (select COUNT(*) from Nfpe as n where n.issuedById = p.id and n.status = 'SENT' and DATE(n.issuedOn) > '2025-01-01' and DATE(n.issuedOn) < '2025-07-01') as '2025 S1',
  (select COUNT(*) from Nfpe as n where n.issuedById = p.id and n.status = 'SENT' and DATE(n.issuedOn) > '2025-06-30' and DATE(n.issuedOn) < '2026-01-01') as '2025 S2',
  (select COUNT(*) from Nfpe as n where n.issuedById = p.id and n.status = 'CANCELLED' and DATE(n.issuedOn) > '2024-12-31' and DATE(n.issuedOn) < '2026-01-01') as 'Canceladas 2025',
  p.addressState, p.addressCity, p.addressCep, p.addressStreet, p.addressNumber, p.addressExtra 
from Person as p where p.type = 'PROPERTY' order by p.legalName
INTO OUTFILE '/var/lib/mysql-files/notas-emitidas-2025-s1.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';
