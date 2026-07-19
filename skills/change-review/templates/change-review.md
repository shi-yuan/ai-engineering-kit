# Change Review

## 1. Review 结论

`PASS | PASS_WITH_NON_BLOCKING_COMMENTS | BLOCKED`

## 1.1 Gate 7 判定

  检查项   结论   证据 / 说明
  -------- ------ ------------
  Diff 完整性      
  Scope            
  Design Conformance
  Verification Alignment
  Context Sync Readiness

## 2. Diff Summary

生成方式：

```powershell
scripts/change-diff-summary.ps1 -ChangeId <change-id> -ProjectRoot <workspace-root>
```

| 检查项 | 结论 | 证据 / 说明 |
|---|---|---|
| 多仓库 Diff 是否完整 | | |
| Design/Tasks 声明路径是否均有实现 | | |
| Diff 文件是否均被 Design/Tasks 覆盖 | | |
| 是否存在超范围修改 | | |
| 是否存在遗漏声明 | | |

## 3. Diff 范围

  仓库   主要变更   Design 是否声明   结论
  ------ ---------- ----------------- ------
                                      

## 4. 需求追溯

  Requirement Delta   Spec   Design   Task   Diff   Verification
  ------------------- ------ -------- ------ ------ --------------
                                                    

## 5. 业务不变量复核

  Invariant ID   相关 Diff   是否保持   证据
  -------------- ----------- ---------- ------
                                        

## 6. Review 问题

  ID       级别   问题   证据   修复要求
  -------- ------ ------ ------ ----------
  CR-001                        

## 7. 跨边界复核

  边界                        检查内容   结论
  --------------------------- ---------- ------
  Interface / RPC                        
  Messaging                              
  Persistence                            
  Job / Compensation                     
  Configuration                          
  Cache                                  
  Transaction / Concurrency              
  Quantity / Permission                  

## 8. Verification 复核

```{=html}
<!-- Verification 是否足够；失败项、未执行项、人工项。 -->
```

## 9. 范围扩张

```{=html}
<!-- 无关重构、未声明仓库修改、非需求修改。 -->
```

## 10. 上线前必须处理

  ID   事项   Owner
  ---- ------ -------

## 11. Context Sync / Archive 阻塞项

  ID        内容   建议落点   是否阻塞 Archive
  -------- ------ ---------- ----------------
  CTX-001
