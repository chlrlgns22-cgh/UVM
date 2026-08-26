#!/usr/bin/env python3
"""python-docx 없이 표준 라이브러리만으로 DOCX 생성"""
import zipfile, io, textwrap

# ── DOCX 내부 XML 빌더 ────────────────────────────────────────────────
NS = 'xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"'

def para(text, style='Normal', bold=False, size=None, color=None, indent=None, mono=False):
    rpr = ''
    if bold:   rpr += '<w:b/>'
    if size:   rpr += f'<w:sz w:val="{size*2}"/><w:szCs w:val="{size*2}"/>'
    if color:  rpr += f'<w:color w:val="{color}"/>'
    if mono:   rpr += '<w:rFonts w:ascii="Courier New" w:hAnsi="Courier New"/>'
    ppr = f'<w:pStyle w:val="{style}"/>'
    if indent: ppr += f'<w:ind w:left="{indent}"/>'
    # escape
    text = text.replace('&','&amp;').replace('<','&lt;').replace('>','&gt;').replace('"','&quot;')
    rpr_tag = f'<w:rPr>{rpr}</w:rPr>' if rpr else ''
    return f'<w:p><w:pPr>{ppr}</w:pPr><w:r>{rpr_tag}<w:t xml:space="preserve">{text}</w:t></w:r></w:p>'

def heading(text, level):
    colors = {1:'1F497D', 2:'2E74B5', 3:'1F3864'}
    color = colors.get(level, '000000')
    style = f'Heading{level}'
    return para(text, style=style, bold=True, color=color)

def tbl(headers, rows):
    def cell(text, bold=False):
        t = text.replace('&','&amp;').replace('<','&lt;').replace('>','&gt;')
        b = '<w:b/>' if bold else ''
        return f'<w:tc><w:p><w:r><w:rPr>{b}</w:rPr><w:t xml:space="preserve">{t}</w:t></w:r></w:p></w:tc>'
    out = '<w:tbl><w:tblPr><w:tblStyle w:val="TableGrid"/><w:tblW w:w="9072" w:type="dxa"/></w:tblPr>'
    out += '<w:tr>' + ''.join(cell(h, bold=True) for h in headers) + '</w:tr>'
    for row in rows:
        out += '<w:tr>' + ''.join(cell(c) for c in row) + '</w:tr>'
    out += '</w:tbl>'
    return out

def pagebreak():
    return '<w:p><w:r><w:br w:type="page"/></w:r></w:p>'

def bullet(text, indent=720):
    return para('• ' + text, indent=indent)

def code(text):
    return para(text, indent=720, mono=True, size=9)

# ── 문서 내용 조립 ────────────────────────────────────────────────────
parts = []
p = parts.append

# 표지
p(para('UVM 검증 환경 설계 보고서 (AXI-Lite GPIO)', bold=True, size=20, color='1F497D'))
p(para('대상 DUT: gpio_v1_0  |  검증 방법론: UVM 1.2  |  시뮬레이터: VCS W-2024.09-SP2'))
p(pagebreak())

# 1. 개요
p(heading('1. 검증 개요', 1))
p(heading('1.1 DUT 기능 요약', 2))
p(para('gpio_v1_0은 AXI4-Lite 슬레이브 인터페이스를 통해 소프트웨어가 8비트 범용 입출력(GPIO) 핀을 제어하는 IP입니다.'))
p(bullet('gpio_v1_0_S00_AXI : AXI4-Lite 프로토콜 처리 및 레지스터 뱅크 관리'))
p(bullet('gpio : CR/ODR/IDR 레지스터를 바탕으로 io_port 핀의 방향·값을 제어'))

p(heading('1.2 레지스터 맵', 2))
p(tbl(
    ['바이트 주소', '레지스터', '접근', '설명'],
    [
        ['0x00', 'CR  (slv_reg0)', 'R/W', '핀 방향 제어. 비트=1→출력, 0→입력'],
        ['0x04', 'IDR (slv_reg1 read)', 'R',   '입력 핀 값 읽기 (idr 신호 반환)'],
        ['0x08', 'ODR (slv_reg2)', 'R/W', '출력 핀 데이터. CR=1인 비트를 구동'],
        ['0x0C', 'slv_reg3', 'R/W', '미사용'],
    ]
))
p(para('GPIO 핀 동작 원리:'))
p(code("assign io_port[i] = cr[i] ? odr[i] : 1'bz;   // 출력 모드"))
p(code("assign idr[i]     = cr[i] ? 1'bz  : io_port[i]; // 입력 모드"))

p(heading('1.3 검증 목표', 2))
p(bullet('AXI4-Lite 쓰기/읽기 핸드셰이크 정확성 검증'))
p(bullet('CR 설정에 따른 출력/입력 핀 동작 정확성 검증'))
p(bullet('ODR 쓰기-읽기 일관성(write-readback) 검증'))
p(bullet('IDR이 외부 입력 핀 값을 정확히 반영하는지 검증'))
p(bullet('기능 커버리지 100% 달성 (cp_cr, cp_odr, cp_io, cx_cr_odr cross)'))
p(pagebreak())

# 2. 아키텍처
p(heading('2. UVM 검증 아키텍처', 1))
p(heading('2.1 전체 구조', 2))
p(para('본 검증 환경은 UVM 1.2 표준 계층 구조를 따릅니다.'))
p(code('tb_top (모듈)'))
p(code('  └─ uvm_root'))
p(code('       └─ gpio_full_cov_test (uvm_test)'))
p(code('            └─ gpio_env (uvm_env)'))
p(code('                 ├─ gpio_agent (uvm_agent)'))
p(code('                 │    ├─ gpio_driver  (uvm_driver)'))
p(code('                 │    ├─ gpio_monitor (uvm_monitor)'))
p(code('                 │    └─ uvm_sequencer'))
p(code('                 ├─ gpio_scoreboard (uvm_scoreboard)'))
p(code('                 └─ gpio_coverage   (uvm_component)'))

p(heading('2.2 데이터 흐름', 2))
p(para('① 테스트가 시퀀스를 실행 → ② 드라이버가 AXI4-Lite 핸드셰이크로 DUT 제어 → ③ 모니터가 버스 트랜잭션 관측 → ④ 분석 포트로 스코어보드·커버리지에 동시 전달'))
p(tbl(
    ['연결', '포트 타입', '설명'],
    [
        ['monitor.ap → scoreboard.imp', 'uvm_analysis_port/imp', '트랜잭션 검증'],
        ['monitor.ap → coverage.analysis_export', 'uvm_analysis_port/imp', '기능 커버리지 수집'],
    ]
))
p(pagebreak())

# 3. 모듈별 설명
p(heading('3. 모듈별 상세 설명', 1))

p(heading('3.1 gpio_if.sv — 시스템베릴로그 인터페이스', 2))
p(para('DUT(AXI 슬레이브)와 TB(AXI 마스터) 간의 모든 신호를 하나의 인터페이스로 묶습니다. Clocking block으로 입출력 방향과 샘플링 타이밍을 명확히 정의합니다.'))
p(bullet('drv_cb: output #0 (클록 엣지 직후 출력), input #1step (에지 직전 샘플링)'))
p(bullet('mon_cb: 모든 신호를 input #1step으로 관측 전용'))
p(bullet('io_port_tb / io_port_tb_en: TB가 입력 모드 핀에 외부값을 구동하기 위한 제어 신호'))
p(para('tb_top에서 tri-state 버스 구성:'))
p(code("assign io_port[i] = io_port_tb_en[i] ? io_port_tb[i] : 1'bz;"))
p(para('io_port_tb_en = ~cr_val 설정으로 출력 모드 비트에서 DUT와 TB 충돌(X) 방지'))

p(heading('3.2 gpio_seq_item.sv — 트랜잭션 데이터 오브젝트', 2))
p(para('1회의 완전한 GPIO 사이클(CR 쓰기 → ODR 쓰기 → IDR 읽기 → ODR 읽기)을 하나의 오브젝트로 추상화합니다.'))
p(tbl(
    ['필드', '타입', '방향', '설명'],
    [
        ['cr_val',       'rand logic[7:0]', '입력', 'CR 레지스터에 쓸 방향 설정값'],
        ['odr_val',      'rand logic[7:0]', '입력', 'ODR 레지스터에 쓸 출력 데이터'],
        ['io_drive',     'rand logic[7:0]', '입력', '입력 모드 핀에 TB가 구동할 외부 값'],
        ['idr_readback', 'logic[7:0]',      '관측', 'IDR 읽기 결과'],
        ['odr_readback', 'logic[7:0]',      '관측', 'ODR 읽기 결과 (write-readback 검증용)'],
        ['bresp',        'logic[1:0]',      '관측', "AXI 쓰기 응답 (OKAY=2'b00 확인)"],
    ]
))

p(heading('3.3 gpio_sequence.sv — 시퀀스', 2))
p(para('드라이버에 전달할 트랜잭션을 생성하는 시나리오 계층입니다. 3종류의 시퀀스가 계층 구조를 이룹니다.'))
p(bullet('gpio_base_seq: do_gpio(cr, odr, io_drv) 헬퍼 태스크 제공'))
p(bullet('gpio_random_seq: item.randomize()로 3개 필드를 랜덤 생성 (기본 num=100)'))
p(bullet('gpio_directed_seq: 커버리지 100% 목표의 31개 고정 패턴 (전체출력4 + 전체입력4 + 혼합23)'))
p(tbl(
    ['패턴 그룹', '대상 bin', '테스트 수'],
    [
        ['전체 출력 (CR=0xFF)', 'all_output × odr 경계값 4종', '4'],
        ['전체 입력 (CR=0x00)', 'all_input × odr_zero (나머지 ignore_bins)', '4'],
        ['CR=0xF0 (high_nibble_out)', 'high_nibble × odr 5종', '5'],
        ['CR=0x0F (low_nibble_out)', 'low_nibble × odr 5종', '5'],
        ['CR=0xAA (alternating_aa)', 'alternating_aa × odr 4종', '4'],
        ['CR=0x55 (alternating_55)', 'alternating_55 × odr 5종', '5'],
        ['합계', '', '27 directed + 4 전체입력 = 31'],
    ]
))

p(heading('3.4 gpio_driver.sv — AXI4-Lite 마스터 드라이버', 2))
p(para('seq_item을 받아 AXI4-Lite 프로토콜에 맞는 핸드셰이크를 구동합니다.'))
p(para('1회 트랜잭션 순서: ① CR 쓰기(0x00) → ② ODR 쓰기(0x08) → ③ io_port_tb 설정(~cr_val) → ④ IDR 읽기(0x04) → ⑤ ODR 읽기(0x08)'))
p(para('이 DUT는 AWVALID와 WVALID가 동시 어서션되어야 AWREADY/WREADY를 반환하는 특성이 있습니다.'))
p(code('m_if.drv_cb.awvalid <= 1; m_if.drv_cb.wvalid <= 1;'))
p(code('do @(m_if.drv_cb); while (!(drv_cb.awready && drv_cb.wready));'))
p(code('// B 채널 완료 대기'))
p(code('do @(m_if.drv_cb); while (!drv_cb.bvalid);'))

p(heading('3.5 gpio_monitor.sv — AXI 트랜잭션 모니터', 2))
p(para('버스를 수동 관측하여 gpio_seq_item을 재조립한 뒤 analysis port로 전송합니다. DUT나 드라이버에 아무 영향도 주지 않습니다.'))
p(tbl(
    ['단계', '감지 조건', '캡처 내용'],
    [
        ['1', 'awvalid & awready & awaddr==0x0', 'cr_val = wdata[7:0]'],
        ['2', 'bvalid & bready', 'bresp'],
        ['3', 'awvalid & awready & awaddr==0x8', 'odr_val = wdata[7:0]'],
        ['4', 'arvalid & arready & araddr==0x4', 'io_drive = io_port_tb & io_port_tb_en'],
        ['5', 'rvalid & rready', 'idr_readback = rdata[7:0]'],
        ['6', 'arvalid & arready & araddr==0x8', '(ODR 읽기 시작)'],
        ['7', 'rvalid & rready', 'odr_readback = rdata[7:0] → ap.write(tr)'],
    ]
))

p(heading('3.6 gpio_scoreboard.sv — 자동 검증기', 2))
p(para('모니터로부터 트랜잭션을 수신하여 3가지 항목을 자동 검증합니다.'))
p(tbl(
    ['항목', '검증 내용', '기대값'],
    [
        ['AXI 응답', 'bresp 확인', "2'b00 (OKAY)"],
        ['ODR 쓰기-읽기 검증', 'odr_readback == odr_val', 'ODR에 쓴 값이 그대로 읽혀야 함'],
        ['IDR 입력 검증', '(idr_readback & ~cr_val) == (io_drive & ~cr_val)', '입력 모드 비트만 마스크하여 비교'],
    ]
))
p(para('IDR 검증에서 ~cr_val 마스크를 사용하는 이유: cr=1(출력)인 비트의 idr은 DUT 내부에서 1\'bz이므로 래치 값이 불확정. 입력 모드 비트만 선택적으로 검증합니다.'))

p(heading('3.7 gpio_coverage.sv — 기능 커버리지', 2))
p(para('검증 시나리오가 기능 공간을 충분히 탐색했는지 정량적으로 측정합니다.'))
p(tbl(
    ['Coverpoint', '대상 신호', 'Bin 구성 (7종)'],
    [
        ['cp_cr', 'cr_val', 'all_output(FF), all_input(00), high_nibble(F0), low_nibble(0F), alternating_aa(AA), alternating_55(55), other(default)'],
        ['cp_odr', 'odr_val', 'odr_zero, odr_max, odr_55, odr_aa, odr_low(01-7F), odr_high(80-FE)'],
        ['cp_io', 'io_drive', 'io_zero, io_max, io_55, io_aa, io_low, io_high'],
        ['cx_cr_odr', 'cross(cp_cr, cp_odr)', 'CR 방향 × ODR 값 조합. ignore_bins 5개 적용'],
    ]
))
p(para('ignore_bins 적용: CR=0x00(전체 입력)일 때 ODR은 핀에 영향 없으므로 all_input × (odr_max/55/aa/low/high) 5가지 조합을 제외하여 달성 가능한 100% 목표를 설정합니다.'))
p(para('VCS get_inst_coverage() 이슈 해결: option.per_instance = 1 필수. 이 옵션 없이는 커버리지가 타입 레벨로만 집계되어 get_inst_coverage()가 항상 0을 반환합니다.'))
p(code('covergroup gpio_cg;'))
p(code('    option.per_instance = 1;  // 필수'))
p(code('    cp_cr: coverpoint cr_v { ... }'))
p(code('endgroup'))

p(heading('3.8 gpio_agent.sv — 에이전트', 2))
p(para('드라이버, 모니터, 시퀀서를 하나로 묶는 재사용 가능한 검증 블록(Active Agent)입니다.'))
p(bullet('build_phase: 드라이버, 모니터, 시퀀서 생성'))
p(bullet('connect_phase: drv.seq_item_port ↔ sqr.seq_item_export 연결'))

p(heading('3.9 gpio_env.sv — 환경', 2))
p(para('에이전트, 스코어보드, 커버리지를 조합하고 분석 포트 팬아웃 연결을 담당합니다.'))
p(code('agt.mon.ap.connect(scb.imp);             // 스코어보드'))
p(code('agt.mon.ap.connect(cov.analysis_export); // 커버리지'))

p(heading('3.10 gpio_test.sv — 테스트', 2))
p(tbl(
    ['테스트 이름', '실행 내용', '목적'],
    [
        ['gpio_directed_test', 'directed_seq 1회 (31개 패턴)', '코너 케이스 빠른 검증'],
        ['gpio_random_test', 'random_seq 100회', '기본 랜덤 검증'],
        ['gpio_full_cov_test', 'directed_seq + random_seq(1000회)', '커버리지 100% 달성'],
    ]
))

p(heading('3.11 tb_top.sv — 테스트벤치 최상위 모듈', 2))
p(para('DUT 인스턴스화, 클록 생성(100MHz), 인터페이스 연결, UVM 환경 구동을 담당합니다.'))
p(para('io_port tri-state 버스:'))
p(code('wire [7:0] io_port;'))
p(code('generate for (gi=0; gi<8; gi++) begin'))
p(code('    assign io_port[gi] = m_if.io_port_tb_en[gi] ? m_if.io_port_tb[gi] : 1\'bz;'))
p(code('end endgenerate'))
p(pagebreak())

# 4. 결과
p(heading('4. 검증 시나리오 및 결과', 1))
p(tbl(
    ['항목', '결과'],
    [
        ['총 트랜잭션 수', '1031 (directed 31 + random 1000)'],
        ['PASS', '1031'],
        ['FAIL', '0'],
        ['UVM_ERROR', '0'],
        ['UVM_FATAL', '0'],
        ['cp_cr 커버리지', '100%'],
        ['cp_odr 커버리지', '100%'],
        ['cp_io 커버리지', '100%'],
        ['cx_cr_odr 커버리지', '100% (ignore_bins 적용 후)'],
    ]
))
p(pagebreak())

# 5. 파일 구조
p(heading('5. 파일 구조 및 빌드 방법', 1))
p(heading('5.1 디렉토리 구조', 2))
p(code('0625_AXI/'))
p(code('├── Makefile'))
p(code('├── rtl/'))
p(code('│   ├── gpio_v1_0.v            ← DUT 최상위'))
p(code('│   └── gpio_v1_0_S00_AXI.v   ← AXI 슬레이브 + 레지스터 뱅크'))
p(code('└── tb/'))
p(code('    ├── gpio_if.sv             ← 인터페이스 + GPIO 핀 제어'))
p(code('    ├── gpio_pkg.sv            ← UVM 패키지'))
p(code('    ├── gpio_seq_item.sv       ← 트랜잭션 오브젝트'))
p(code('    ├── gpio_sequence.sv       ← random / directed 시퀀스'))
p(code('    ├── gpio_driver.sv         ← AXI4-Lite 마스터'))
p(code('    ├── gpio_monitor.sv        ← 버스 관측기'))
p(code('    ├── gpio_agent.sv          ← 에이전트'))
p(code('    ├── gpio_scoreboard.sv     ← 자동 검증기'))
p(code('    ├── gpio_coverage.sv       ← 기능 커버리지'))
p(code('    ├── gpio_env.sv            ← 검증 환경'))
p(code('    ├── gpio_test.sv           ← 테스트 3종'))
p(code('    └── tb_top.sv              ← 최상위 모듈'))

p(heading('5.2 빌드 명령', 2))
p(tbl(
    ['명령', '설명'],
    [
        ['make', 'comp + simv 전체 실행 (기본: gpio_full_cov_test)'],
        ['make TEST=gpio_directed_test', 'directed 테스트만 실행'],
        ['make SEED=42', '랜덤 시드 지정'],
        ['make INFO_LEVEL=UVM_HIGH', '상세 로그 출력'],
        ['make clean', '생성 파일 삭제'],
    ]
))
p(pagebreak())

# 6. 설계 결정 요약
p(heading('6. 주요 설계 결정 이유', 1))
p(tbl(
    ['설계 결정', '이유'],
    [
        ['GPIO 레벨 추상화 (seq_item 1개 = 1 GPIO 사이클)',
         '개별 AXI 트랜잭션이 아닌 GPIO 설정+검증 단위로 추상화하여 시퀀스 작성과 스코어보드 검증을 단순화'],
        ['io_port_tb_en = ~cr_val',
         'inout 핀에서 DUT와 TB가 같은 비트를 동시 구동하면 X 발생. 출력 모드 비트는 TB가 Hi-Z 유지'],
        ['IDR 검증 시 ~cr_val 마스크',
         "출력 모드(cr=1) 비트의 idr은 DUT에서 1'bz로 불확정. 입력 모드 비트만 선택적 검증"],
        ['ignore_bins all_input×odr_*',
         'CR=0x00일 때 ODR은 핀에 영향 없으므로 달성 불가능한 cross bin 제거. 실현 가능한 100% 목표'],
        ['option.per_instance = 1',
         'VCS에서 get_inst_coverage()는 이 옵션 없이 항상 0 반환. 터미널 실시간 리포트 정상화'],
        ['drv_cb output #0 / input #1step',
         '#0: 클록 직후 출력으로 DUT가 같은 사이클에 인식. #1step: 에지 직전 샘플링으로 race condition 방지'],
        ['uvm_init.sh 자동화 스크립트',
         '매 프로젝트마다 동일한 UVM 뼈대를 수작업으로 만드는 낭비 제거. prefix만 바꿔 재사용 가능'],
    ]
))

# ── DOCX XML 조립 ─────────────────────────────────────────────────────
body_xml = '\n'.join(parts)

doc_xml = f'''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document {NS}
  xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
  xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing">
<w:body>
{body_xml}
</w:body>
</w:document>'''

styles_xml = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:style w:type="paragraph" w:styleId="Normal"><w:name w:val="Normal"/>
    <w:rPr><w:rFonts w:ascii="Malgun Gothic" w:hAnsi="Malgun Gothic"/><w:sz w:val="20"/></w:rPr></w:style>
  <w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/>
    <w:pPr><w:numPr><w:ilvl w:val="0"/></w:numPr><w:spacing w:before="240" w:after="120"/></w:pPr>
    <w:rPr><w:rFonts w:ascii="Malgun Gothic" w:hAnsi="Malgun Gothic"/>
      <w:b/><w:sz w:val="32"/><w:color w:val="1F497D"/></w:rPr></w:style>
  <w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/>
    <w:pPr><w:spacing w:before="200" w:after="100"/></w:pPr>
    <w:rPr><w:rFonts w:ascii="Malgun Gothic" w:hAnsi="Malgun Gothic"/>
      <w:b/><w:sz w:val="26"/><w:color w:val="2E74B5"/></w:rPr></w:style>
  <w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3"/>
    <w:pPr><w:spacing w:before="160" w:after="80"/></w:pPr>
    <w:rPr><w:rFonts w:ascii="Malgun Gothic" w:hAnsi="Malgun Gothic"/>
      <w:b/><w:sz w:val="22"/><w:color w:val="1F3864"/></w:rPr></w:style>
  <w:style w:type="table" w:styleId="TableGrid"><w:name w:val="Table Grid"/>
    <w:tblPr><w:tblBorders>
      <w:top w:val="single" w:sz="4"/><w:left w:val="single" w:sz="4"/>
      <w:bottom w:val="single" w:sz="4"/><w:right w:val="single" w:sz="4"/>
      <w:insideH w:val="single" w:sz="4"/><w:insideV w:val="single" w:sz="4"/>
    </w:tblBorders></w:tblPr></w:style>
</w:styles>'''

rels_xml = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles"
    Target="styles.xml"/>
</Relationships>'''

content_types = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  <Override PartName="/word/document.xml"
    ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>
  <Override PartName="/word/styles.xml"
    ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/>
</Types>'''

pkg_rels = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1"
    Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument"
    Target="word/document.xml"/>
</Relationships>'''

# ── ZIP 파일로 묶기 ───────────────────────────────────────────────────
import sys
out_path = '/home/pedu34/workspace/UVM_GPIO_report.docx'
try:
    with zipfile.ZipFile(out_path, 'w', zipfile.ZIP_DEFLATED) as z:
        z.writestr('[Content_Types].xml', content_types.encode('utf-8'))
        z.writestr('_rels/.rels', pkg_rels.encode('utf-8'))
        z.writestr('word/document.xml', doc_xml.encode('utf-8'))
        z.writestr('word/styles.xml', styles_xml.encode('utf-8'))
        z.writestr('word/_rels/document.xml.rels', rels_xml.encode('utf-8'))
    print(f'OK: {out_path}')
except Exception as e:
    print(f'ERROR: {e}', file=sys.stderr)
    sys.exit(1)
