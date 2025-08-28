1. In a large-scale enterprise, how would you architect a data pipeline to ensure exactly-once delivery semantics while processing streaming data from multiple heterogeneous sources with differing SLAs and schema evolution requirements?
Ans B Implement idempotency at sink and watermarking for schema evolution

2. When designing a highly available, globally distributed relational database supporting strong consistency and low-latency queries, which strategies or technologies are MOST appropriate to address consistency, latency, and failover challenges?
Synchronous cross-region replication
Distributed consensus algorithms like Paxos or Raft
Multi-master replication with conflict resolution

3. A multinational organization faces strict data residency, privacy, and regulatory requirements. Which data architecture pattern best enables global analytics while ensuring compliance, scalability, and minimal data duplication?
D Data mesh with federated governance

4. For petabyte-scale data lakes supporting multi-tenant analytical workloads, what are the most effective multiple strategies to ensure data consistency, fine-grained access control, and cost-efficient storage management?
A Implement row-level security via data lake catalog
C Leverage ACID-compliant file formats like Delta Lake

5. Within a hybrid cloud environment, which big data platform architecture offers the best balance of scalability, cost, and operational resilience for real-time analytics on structured and unstructured data?
B Cloud-native serverless data platform with autoscaling

6. Which multple advanced techniques are critical for ensuring transactional integrity, high throughput, and minimal contention in OLTP relational databases at scale?
A Optimistic concurrency control and row-level locking
B Write-ahead logging and snapshot isolation
E Horizontal partitioning (sharding)    

7. Given a scenario where OLAP and OLTP workloads must be served simultaneously from a relational database, which architectural approach BEST addresses performance and resource isolation challenges?
A Hybrid transactional/analytical processing (HTAP) platform   

8. Which mltiple advanced features are essential for production-grade big data platforms supporting streaming, batch, and interactive analytics across diverse data sources?
A Unified metadata catalog 
C Native support for ACID transactions  
D Real-time data lineage tracking
E Elastic resource provisioning
