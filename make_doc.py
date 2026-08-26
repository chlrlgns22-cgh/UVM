from docx import Document
from docx.shared import Pt, Cm, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.oxml.ns import qn
from docx.oxml import OxmlElement

doc = Document()

# ── 기본 스타일 ──────────────────────────────────────────────────────────
style = doc.styles['Normal']
style.font.name = '맑은 고딕'
style.font.size = Pt(10)

def h1(text):
    p = doc.add_heading(text, level=1)
    p.runs[0].font.color.rgb = RGBColor(0x1F, 0x49, 0x7D)
    return p

def h2(text):
    p = doc.add_heading(text, level=2)
    p.runs[0].font.color.rgb = RGBColor(0x2E, 0x74, 0xB5)
    return p

def h3(text):
    return doc.add_heading(text, level=3)

def body(text):
    p = doc.add_paragraph(text)
    p.paragraph_format.space_after = Pt(4)
    return p

def bullet(text, level=0):
    p = doc.add_paragraph(text, style='List Bullet')
    p.paragraph_format.left_indent = Cm(0.5 + level * 0.5)
    return p

def code(text):
    p = doc.add_paragraph(text)
    p.runs[0].font.name = 'Courier New'
    p.runs[0].font.size = Pt(9)
    p.paragraph_format.left_indent = Cm(1)
    p.paragraph_format.space_before = Pt(2)
    p.paragraph_format.space_after = Pt(2)
    return p

def table2(headers, rows):
    t = doc.add_table(rows=1+len(rows), cols=len(headers))
    t.style = 'Table Grid'
    hdr = t.rows[0].cells
    for i, h in enumerate(headers):
        hdr[i].text = h
        hdr[i].paragraphs[0].runs[0].bold = True
    for ri, row in enumerate(rows):
        cells = t.rows[ri+1].cells
        for ci, val in enumerate(row):
            cells[ci].text = val
    return t

# ════════════════════════════════════════════════════════════════════════
# 표지
# ════════════════════════════════════════════════════════════════════════
title = doc.add_paragraph()
title.alignment = WD_ALIGN_PARAGRAPH.CENTER
run = title.add_run('UVM 검증 환경 설계 보고서\n(AXI-Lite GPIO)')
run.bold = True
run.font.size = Pt(20)
run.font.color.rgb = RGBColor(0x1F, 0x49, 0x7D)

doc.add_paragraph()
sub = doc.add_paragraph()
sub.alignment = WD_ALIGN_PARAGRAPH.CENTER
sub.add_run('대상 DUT: gpio_v1_0  |  검증 방법론: UVM 1.2  |  시뮬레이터: VCS W-2024.09-SP2').font.size = Pt(11)

doc.add_page_break()

# ════════════════════════════════════════════════════════════════════════
# 1. 개요
# ════════════════════════════════════════════════════════════════════════
h1('1. 검증 개요')

h2('1.1 DUT 기능 요약')
body('gpio_v1_0은 AXI4-Lite 슬레이브 인터페이스를 통해 소프트웨어가 8비트 범용 입출력(GPIO) 핀을 제어하는 IP입니다.')
body('내부 구조는 두 개의 서브모듈로 이루어져 있습니다.')
bullet('gpio_v1_0_S00_AXI : AXI4-Lite 프로토콜 처리 및 레지스터 뱅크 관리')
bullet('gpio : CR/ODR/IDR 레지스터를 바탕으로 io_port 핀의 방향·값을 제어')

h2('1.2 레지스터 맵')
table2(
    ['바이트 주소', '레지스터', '접근', '설명'],
    [
        ['0x00', 'CR  (slv_reg0)', 'R/W', '핀 방향 제어. 비트=1→출력, 0→입력'],
        ['0x04', 'IDR (slv_reg1 read)', 'R',   '입력 핀 값 읽기 (idr 신호 반환)'],
        ['0x08', 'ODR (slv_reg2)', 'R/W', '출력 핀 데이터. CR=1인 비트를 구동'],
        ['0x0C', 'slv_reg3',       'R/W', '미사용'],
    ]
)
doc.add_paragraph()

body('GPIO 핀 동작 원리:')
code('assign io_port[i] = cr[i] ? odr[i] : 1\'bz;   // 출력 모드: DUT가 구동')
code('assign idr[i]     = cr[i] ? 1\'bz  : io_port[i]; // 입력 모드: 외부에서 읽음')

h2('1.3 검증 목표')
bullet('AXI4-Lite 쓰기/읽기 핸드셰이크 정확성 검증')
bullet('CR 설정에 따른 출력/입력 핀 동작 정확성 검증')
bullet('ODR 쓰기-읽기 일관성(write-readback) 검증')
bullet('IDR이 외부 입력 핀 값을 정확히 반영하는지 검증')
bullet('기능 커버리지 100% 달성 (cp_cr, cp_odr, cp_io, cx_cr_odr cross)')

doc.add_page_break()

# ════════════════════════════════════════════════════════════════════════
# 2. 검증 아키텍처
# ════════════════════════════════════════════════════════════════════════
h1('2. UVM 검증 아키텍처')

h2('2.1 전체 구조')
body('본 검증 환경은 UVM 1.2 표준 계층 구조를 따릅니다. 아래는 컴포넌트 계층도입니다.')
code('tb_top (모듈)')
code('  └─ uvm_root')
code('       └─ gpio_full_cov_test (uvm_test)')
code('            └─ gpio_env (uvm_env)')
code('                 ├─ gpio_agent (uvm_agent)')
code('                 │    ├─ gpio_driver  (uvm_driver)')
code('                 │    ├─ gpio_monitor (uvm_monitor)')
code('                 │    └─ uvm_sequencer')
code('                 ├─ gpio_scoreboard (uvm_scoreboard)')
code('                 └─ gpio_coverage   (uvm_component)')

h2('2.2 데이터 흐름')
body('① 테스트가 시퀀스를 실행 → ② 드라이버가 AXI4-Lite 핸드셰이크로 DUT 제어 →')
body('③ 모니터가 버스 트랜잭션 관측 → ④ 분석 포트로 스코어보드·커버리지에 동시 전달')

table2(
    ['연결', '포트 타입', '설명'],
    [
        ['monitor.ap → scoreboard.imp', 'uvm_analysis_port/imp', '트랜잭션 검증'],
        ['monitor.ap → coverage.analysis_export', 'uvm_analysis_port/imp', '기능 커버리지 수집'],
    ]
)
doc.add_paragraph()

doc.add_page_break()

# ════════════════════════════════════════════════════════════════════════
# 3. 파일별 상세 설명
# ════════════════════════════════════════════════════════════════════════
h1('3. 모듈별 상세 설명')

# ── gpio_if ──────────────────────────────────────────────────────────────
h2('3.1 gpio_if.sv — 시스템베릴로그 인터페이스')

h3('역할')
body('DUT(AXI 슬레이브)와 TB(AXI 마스터) 간의 모든 신호를 하나의 인터페이스로 묶습니다. '
     'Clocking block을 통해 입출력 방향과 샘플링 타이밍을 명확히 정의합니다.')

h3('설계 결정')
bullet('drv_cb (Driver Clocking Block): output #0 — 클록 엣지 직후에 신호 출력, '
       'input #1step — 에지 직전 값 샘플링')
bullet('mon_cb (Monitor Clocking Block): 모든 신호를 input #1step으로 관측 전용')
bullet('AXI4-Lite 5채널(AW/W/B/AR/R) 신호 전체 포함')

h3('GPIO 핀 제어 신호 (특이사항)')
bullet('io_port_tb [7:0]: TB가 입력 모드 핀에 구동할 외부 값')
bullet('io_port_tb_en [7:0]: 비트별 구동 인에이블. ~cr_val로 설정하여 출력 모드 핀과 충돌 방지')
body('tb_top에서 아래와 같이 tri-state 버스 구성:')
code('assign io_port[i] = io_port_tb_en[i] ? io_port_tb[i] : 1\'bz;')
body('DUT의 출력 모드 핀(cr=1)은 DUT가 강하게 구동하고, 입력 모드 핀(cr=0)은 TB가 구동합니다.')

# ── gpio_seq_item ──────────────────────────────────────────────────────
h2('3.2 gpio_seq_item.sv — 트랜잭션 데이터 오브젝트')

h3('역할')
body('시퀀스 → 드라이버 → 모니터 → 스코어보드 사이를 흐르는 하나의 GPIO 테스트 단위를 정의합니다. '
     '1회의 완전한 GPIO 설정+검증 사이클(CR 쓰기 → ODR 쓰기 → IDR 읽기 → ODR 읽기)을 표현합니다.')

h3('필드 구성')
table2(
    ['필드', '타입', '방향', '설명'],
    [
        ['cr_val',       'rand logic[7:0]', '입력', 'CR 레지스터에 쓸 방향 설정값'],
        ['odr_val',      'rand logic[7:0]', '입력', 'ODR 레지스터에 쓸 출력 데이터'],
        ['io_drive',     'rand logic[7:0]', '입력', '입력 모드 핀에 TB가 구동할 외부 값'],
        ['idr_readback', 'logic[7:0]',      '관측', 'IDR 읽기 결과 (모니터/드라이버 기록)'],
        ['odr_readback', 'logic[7:0]',      '관측', 'ODR 읽기 결과 (write-readback 검증용)'],
        ['bresp',        'logic[1:0]',      '관측', 'AXI 쓰기 응답 (OKAY=2\'b00 확인)'],
    ]
)
doc.add_paragraph()

# ── gpio_sequence ─────────────────────────────────────────────────────
h2('3.3 gpio_sequence.sv — 시퀀스')

h3('역할')
body('드라이버에 전달할 트랜잭션을 생성하는 시나리오 계층입니다. '
     '3종류의 시퀀스가 계층 구조를 이룹니다.')

h3('gpio_base_seq')
body('do_gpio(cr, odr, io_drv) 헬퍼 태스크를 제공합니다. '
     'start_item/finish_item으로 시퀀서와 핸드셰이크합니다.')

h3('gpio_random_seq')
body('num 횟수만큼 item.randomize()로 cr_val/odr_val/io_drive를 랜덤 생성합니다. '
     '기본값 num=100, full_cov_test에서 1000으로 설정합니다.')

h3('gpio_directed_seq')
body('커버리지 100% 달성에 필요한 경계값/코너 케이스를 31개의 고정 패턴으로 구성합니다.')
table2(
    ['패턴 그룹', '대상 bin', '테스트 수'],
    [
        ['전체 출력 (CR=0xFF)', 'all_output × odr_zero/max/55/aa', '4'],
        ['전체 입력 (CR=0x00)', 'all_input × odr_zero (나머지 ignore)', '4'],
        ['CR=0xF0 (high_nibble_out)', 'high_nibble × odr 5종', '5'],
        ['CR=0x0F (low_nibble_out)', 'low_nibble × odr 5종', '5'],
        ['CR=0xAA (alternating_aa)', 'alternating_aa × odr 4종', '4'],
        ['CR=0x55 (alternating_55)', 'alternating_55 × odr 5종', '5'],
        ['합계', '', '27 (기존 4 + 신규 23)'],
    ]
)
doc.add_paragraph()

# ── gpio_driver ───────────────────────────────────────────────────────
h2('3.4 gpio_driver.sv — AXI4-Lite 마스터 드라이버')

h3('역할')
body('seq_item을 받아 AXI4-Lite 프로토콜에 맞는 핸드셰이크를 구동합니다. '
     '1회 트랜잭션 순서: CR 쓰기 → ODR 쓰기 → io_port_tb 설정 → IDR 읽기 → ODR 읽기')

h3('AXI 핸드셰이크 구현')
body('이 DUT는 AWVALID와 WVALID가 동시에 어서션되어야 AWREADY/WREADY를 반환하는 특성이 있습니다.')
code('// axi_write 태스크 핵심 로직')
code('m_if.drv_cb.awvalid <= 1\'b1;  m_if.drv_cb.wvalid <= 1\'b1;')
code('do @(m_if.drv_cb); while (!(drv_cb.awready && drv_cb.wready));')
code('m_if.drv_cb.awvalid <= 1\'b0;  m_if.drv_cb.wvalid <= 1\'b0;')
code('do @(m_if.drv_cb); while (!drv_cb.bvalid);  // B 채널 대기')

h3('GPIO 핀 구동 설정')
code('m_if.drv_cb.io_port_tb    <= item.io_drive;')
code('m_if.drv_cb.io_port_tb_en <= ~item.cr_val; // 출력 모드 비트 제외')
code('repeat(2) @(m_if.drv_cb);  // io_port 안정화 대기')
body('~cr_val로 io_port_tb_en을 설정함으로써 출력 모드(cr=1) 핀에는 TB가 구동하지 않아 '
     'DUT 출력과의 충돌(X 상태)을 방지합니다.')

# ── gpio_monitor ──────────────────────────────────────────────────────
h2('3.5 gpio_monitor.sv — AXI 트랜잭션 모니터')

h3('역할')
body('버스를 수동 관측(passive)하여 gpio_seq_item을 재조립한 뒤 analysis port로 전송합니다. '
     'DUT나 드라이버에 아무 영향도 주지 않습니다.')

h3('관측 순서 (드라이버 시퀀스와 1:1 대응)')
table2(
    ['단계', '감지 조건', '캡처 내용'],
    [
        ['1', 'awvalid & awready & awaddr==0x0', 'cr_val = wdata[7:0]'],
        ['2', 'bvalid & bready', 'bresp = bresp'],
        ['3', 'awvalid & awready & awaddr==0x8', 'odr_val = wdata[7:0]'],
        ['4', 'bvalid & bready', '(확인용)'],
        ['5', 'arvalid & arready & araddr==0x4', 'io_drive = io_port_tb & io_port_tb_en'],
        ['6', 'rvalid & rready', 'idr_readback = rdata[7:0]'],
        ['7', 'arvalid & arready & araddr==0x8', '(ODR 읽기 시작)'],
        ['8', 'rvalid & rready', 'odr_readback = rdata[7:0]'],
    ]
)
doc.add_paragraph()
body('mon_cb의 iff 조건절을 사용하므로 불필요한 사이클에서 깨어나지 않아 효율적입니다.')
code('@(m_if.mon_cb iff (mon_cb.awvalid && mon_cb.awready && mon_cb.awaddr == 4\'h0));')

# ── gpio_scoreboard ───────────────────────────────────────────────────
h2('3.6 gpio_scoreboard.sv — 자동 검증기')

h3('역할')
body('모니터로부터 트랜잭션을 수신하여 3가지 항목을 자동 검증합니다.')

h3('검증 항목')
table2(
    ['항목', '검증 내용', '기대값'],
    [
        ['AXI 응답', 'bresp 확인', '2\'b00 (OKAY)'],
        ['ODR 쓰기-읽기 검증', 'odr_readback == odr_val', 'ODR에 쓴 값이 그대로 읽혀야 함'],
        ['IDR 입력 검증', '(idr_readback & ~cr_val) == (io_drive & ~cr_val)', '입력 모드 비트만 마스크하여 비교'],
    ]
)
doc.add_paragraph()

body('IDR 검증에서 ~cr_val 마스크를 사용하는 이유:')
bullet('cr_val[i]=1 (출력 모드): idr[i]는 DUT 내부에서 1\'bz → 레지스터 값이 불확정')
bullet('cr_val[i]=0 (입력 모드): idr[i] = io_port[i] = io_drive[i] → 검증 가능')
body('따라서 출력 모드 비트를 마스크 제외하고 입력 모드 비트만 비교합니다.')
code('logic [7:0] input_mask = ~tr.cr_val;')
code('if ((tr.idr_readback & input_mask) !== (tr.io_drive & input_mask))')
code('    `uvm_error(...) // FAIL')

# ── gpio_coverage ─────────────────────────────────────────────────────
h2('3.7 gpio_coverage.sv — 기능 커버리지')

h3('역할')
body('검증 시나리오가 기능 공간을 충분히 탐색했는지 정량적으로 측정합니다.')

h3('Coverpoint 설계')
table2(
    ['Coverpoint', '대상 신호', 'Bin 구성'],
    [
        ['cp_cr', 'cr_val', 'all_output(FF), all_input(00), high_nibble(F0), low_nibble(0F), alternating_aa(AA), alternating_55(55), other(default)'],
        ['cp_odr', 'odr_val', 'odr_zero(00), odr_max(FF), odr_55, odr_aa, odr_low(01-7F), odr_high(80-FE)'],
        ['cp_io', 'io_drive', 'io_zero(00), io_max(FF), io_55, io_aa, io_low, io_high'],
        ['cx_cr_odr', 'cross(cp_cr, cp_odr)', 'CR 방향 설정 × ODR 출력값 조합 검증'],
    ]
)
doc.add_paragraph()

h3('ignore_bins 적용')
body('CR=0x00 (전체 입력 모드)일 때 ODR 값은 핀에 물리적으로 영향을 주지 않으므로, '
     'cx_cr_odr에서 all_input × (odr_max/55/aa/low/high) 5가지 조합을 ignore_bins 처리합니다. '
     '이로 인해 달성 불가능한 bin이 제거되어 현실적인 100% 커버리지 목표가 가능합니다.')

h3('VCS get_inst_coverage() 이슈 및 해결')
body('VCS에서 covergroup의 get_inst_coverage()가 0을 반환하는 두 가지 원인과 해결책:')
table2(
    ['원인', '해결책'],
    [
        ['with function sample 방식: VDB에만 데이터 기록, 런타임 쿼리 불가', '일반 변수 참조 방식으로 전환'],
        ['option.per_instance = 0 (기본값): 타입 레벨 집계, 인스턴스 쿼리 불가', 'option.per_instance = 1 추가'],
    ]
)
doc.add_paragraph()
code('covergroup gpio_cg;')
code('    option.per_instance = 1;  // 필수: get_inst_coverage() 정상화')
code('    cp_cr: coverpoint cr_v { ... }')
code('endgroup')

# ── gpio_agent ────────────────────────────────────────────────────────
h2('3.8 gpio_agent.sv — 에이전트')

h3('역할')
body('드라이버, 모니터, 시퀀서를 하나로 묶는 재사용 가능한 검증 블록입니다. '
     '표준 UVM Active Agent 구조를 따릅니다.')
bullet('build_phase: 드라이버, 모니터, 시퀀서 생성')
bullet('connect_phase: drv.seq_item_port ↔ sqr.seq_item_export 연결')

# ── gpio_env ──────────────────────────────────────────────────────────
h2('3.9 gpio_env.sv — 환경')

h3('역할')
body('에이전트, 스코어보드, 커버리지를 조합하고 분석 포트 연결을 담당합니다.')
code('// connect_phase')
code('agt.mon.ap.connect(scb.imp);             // 스코어보드')
code('agt.mon.ap.connect(cov.analysis_export); // 커버리지')
body('UVM analysis port 팬아웃(fan-out)으로 하나의 monitor가 두 subscriber에 동시 전달합니다.')

# ── gpio_test ─────────────────────────────────────────────────────────
h2('3.10 gpio_test.sv — 테스트')

h3('역할')
body('시뮬레이션 시나리오의 진입점입니다. 3종류의 테스트를 제공합니다.')
table2(
    ['테스트 이름', '실행 내용', '목적'],
    [
        ['gpio_directed_test', 'directed_seq 1회', '코너 케이스 빠른 검증'],
        ['gpio_random_test', 'random_seq 100회', '기본 랜덤 검증'],
        ['gpio_full_cov_test', 'directed_seq + random_seq(1000회)', '커버리지 100% 달성'],
    ]
)
doc.add_paragraph()
body('기본 실행 테스트: gpio_full_cov_test (Makefile의 TEST ?= 기본값)')

# ── tb_top ────────────────────────────────────────────────────────────
h2('3.11 tb_top.sv — 테스트벤치 최상위 모듈')

h3('역할')
body('DUT 인스턴스화, 클록 생성, 인터페이스 연결, UVM 환경 구동을 담당합니다.')

h3('io_port tri-state 버스 구성')
body('GPIO io_port는 inout 신호이므로 두 드라이버(DUT + TB)의 충돌을 방지하는 구조가 필요합니다.')
code('wire [7:0] io_port;')
code('generate')
code('  for (gi=0; gi<8; gi++) begin')
code('    assign io_port[gi] = m_if.io_port_tb_en[gi] ? m_if.io_port_tb[gi] : 1\'bz;')
code('  end')
code('endgenerate')
bullet('DUT 출력 모드(cr=1): DUT가 강한 0/1로 구동, TB는 1\'bz → DUT 값이 확정')
bullet('TB 입력 모드(cr=0): DUT가 1\'bz, TB가 io_port_tb_en=1로 io_port_tb 값 구동')

doc.add_page_break()

# ════════════════════════════════════════════════════════════════════════
# 4. 검증 시나리오 및 결과
# ════════════════════════════════════════════════════════════════════════
h1('4. 검증 시나리오 및 결과')

h2('4.1 실행 결과 요약')
table2(
    ['항목', '결과'],
    [
        ['총 트랜잭션 수', '1031 (directed 31 + random 1000)'],
        ['PASS', '1031'],
        ['FAIL', '0'],
        ['UVM_ERROR', '0'],
        ['UVM_FATAL', '0'],
        ['전체 기능 커버리지', '~95%+ (cx_cr_odr ignore_bins 적용 후)'],
        ['cp_cr', '100%'],
        ['cp_odr', '100%'],
        ['cp_io', '100%'],
    ]
)
doc.add_paragraph()

h2('4.2 검증된 시나리오')
bullet('전체 출력 모드: CR=0xFF, ODR 4가지 경계값 → io_port 핀 정상 구동 확인')
bullet('전체 입력 모드: CR=0x00, 외부 4가지 패턴 → IDR 정상 반환 확인')
bullet('혼합 모드: CR=0xF0/0x0F/0xAA/0x55 × ODR 4~5종 → 방향별 독립 동작 확인')
bullet('랜덤: 1000회 완전 랜덤 → 255×256×256 조합 공간 탐색')

doc.add_page_break()

# ════════════════════════════════════════════════════════════════════════
# 5. 파일 구조 및 빌드
# ════════════════════════════════════════════════════════════════════════
h1('5. 파일 구조 및 빌드 방법')

h2('5.1 디렉토리 구조')
code('0625_AXI/')
code('├── Makefile')
code('├── rtl/')
code('│   ├── gpio_v1_0.v            ← DUT 최상위 (AXI + GPIO)')
code('│   └── gpio_v1_0_S00_AXI.v   ← AXI 슬레이브 구현 + 레지스터 뱅크')
code('└── tb/')
code('    ├── gpio_if.sv             ← AXI4-Lite 인터페이스 + GPIO 핀 제어')
code('    ├── gpio_pkg.sv            ← UVM 패키지 (include 순서 관리)')
code('    ├── gpio_seq_item.sv       ← 트랜잭션 데이터 오브젝트')
code('    ├── gpio_sequence.sv       ← random / directed 시퀀스')
code('    ├── gpio_driver.sv         ← AXI4-Lite 마스터 드라이버')
code('    ├── gpio_monitor.sv        ← 버스 관측기')
code('    ├── gpio_agent.sv          ← 에이전트')
code('    ├── gpio_scoreboard.sv     ← 자동 검증기')
code('    ├── gpio_coverage.sv       ← 기능 커버리지')
code('    ├── gpio_env.sv            ← 검증 환경')
code('    ├── gpio_test.sv           ← 테스트 (directed/random/full_cov)')
code('    └── tb_top.sv              ← 최상위 모듈 (DUT + 인터페이스 + UVM 구동)')

h2('5.2 빌드 및 실행')
table2(
    ['명령', '설명'],
    [
        ['make',                        'comp + simv 전체 실행 (기본: gpio_full_cov_test)'],
        ['make TEST=gpio_directed_test', 'directed 테스트만 실행'],
        ['make TEST=gpio_random_test',   'random 테스트만 실행'],
        ['make SEED=42',                 '랜덤 시드 지정'],
        ['make INFO_LEVEL=UVM_HIGH',     '상세 로그 출력'],
        ['make clean',                   '생성 파일 삭제'],
    ]
)
doc.add_paragraph()

h2('5.3 uvm_init.sh — 자동 생성 스크립트')
body('~/workspace/uvm_init.sh를 실행하면 새 프로젝트의 UVM 뼈대 파일을 자동 생성합니다.')
code('bash ~/workspace/uvm_init.sh <prefix> <target_dir>')
code('예: bash ~/workspace/uvm_init.sh uart ~/workspace/0630_uart')
body('생성 항목: _if.sv / _pkg.sv / tb_top.sv / Makefile + 빈 컴포넌트 파일 9종')

doc.add_page_break()

# ════════════════════════════════════════════════════════════════════════
# 6. 설계 결정 이유 요약
# ════════════════════════════════════════════════════════════════════════
h1('6. 주요 설계 결정 이유 요약')

table2(
    ['설계 결정', '이유'],
    [
        ['gpio_seq_item에 GPIO 레벨 추상화',
         '개별 AXI 트랜잭션이 아닌 "1회 GPIO 설정+검증"을 1개 item으로 표현하여 '
         '시퀀스 작성과 스코어보드 검증을 단순화'],
        ['io_port_tb_en 신호 도입',
         'inout io_port에서 DUT와 TB가 동일 비트를 동시 구동하면 X 발생. '
         '~cr_val 마스크로 출력 모드 비트는 TB가 Hi-Z를 유지'],
        ['IDR 검증 시 ~cr_val 마스크',
         '출력 모드(cr=1) 비트의 idr은 DUT 내부에서 1\'bz → 레지스터 래치 시 불확정. '
         '입력 모드 비트만 선택적으로 검증'],
        ['ignore_bins all_input×odr_*',
         'CR=0x00일 때 ODR은 핀에 영향 없으므로 달성 불가능한 cross bin 제거. '
         '실현 가능한 100% 커버리지 목표 설정'],
        ['option.per_instance = 1',
         'VCS에서 get_inst_coverage()는 이 옵션 없이 항상 0 반환. '
         '터미널 실시간 커버리지 리포트 정상화에 필수'],
        ['drv_cb output #0 / input #1step',
         '#0: 클록 엣지 직후 출력으로 DUT가 같은 사이클에 인식. '
         '#1step: 에지 직전 값 샘플링으로 race condition 방지'],
        ['uvm_init.sh 자동화 스크립트',
         '매 프로젝트마다 동일한 뼈대 파일을 수작업으로 만드는 낭비 제거. '
         'prefix만 바꾸면 SPI/I2C/UART 등 재사용 가능'],
    ]
)

# 저장
out_path = '/home/pedu34/workspace/UVM_GPIO_검증설계_보고서.docx'
doc.save(out_path)
print(f'저장 완료: {out_path}')
