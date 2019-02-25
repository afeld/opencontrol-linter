# frozen_string_literal: true

require 'timeout'
require 'opencontrol'

RSpec.describe 'Opencontrol CLI' do
  context 'when checking basic output' do
    it 'outputs a correct help string' do
      expect do
        Opencontrol::CLI.run_with_args(['--help'])
      end.to output(/usage: opencontrol-linter/).to_stdout
    end
    it 'outputs a correct version string' do
      expect do
        Opencontrol::CLI.run_with_args(['--version'])
      end.to output(/Opencontrol linter version/).to_stdout
    end
  end

  context 'when parsing command line arguments for general commands' do
    it 'specifies an action of :help when given the help flag' do
      s = Opencontrol::CLI.parse_args(['--help'])
      expect(s[:action]).to eq(:help)
      s = Opencontrol::CLI.parse_args(['-h'])
      expect(s[:action]).to eq(:help)
    end
    it 'specifies an action of :version when given the version flag' do
      s = Opencontrol::CLI.parse_args(['--version'])
      expect(s[:action]).to eq(:version)
      s = Opencontrol::CLI.parse_args(['-v'])
      expect(s[:action]).to eq(:version)
    end
    it 'specifies an action of :run when given no args or args for all' do
      [['--all'], ['-a'], ['']].each do |a|
        s = Opencontrol::CLI.parse_args(a)
        expect(s[:action]).to eq(:run)
        expect(s[:targets].length).to eq(4)
        expect(s).to eq(Opencontrol::CLI::DEFAULT_SPECIFICATION)
      end
    end
  end

  context 'when parsing command line arguments for a single type' do
    it 'specifies the correct target when asked to just run components' do
      [['--components'], ['--component'], ['-c']].each do |a|
        s = Opencontrol::CLI.parse_args(a)
        expect(s[:action]).to eq(:run)
        expect(s[:targets].length).to eq(1)
        expect(s[:targets][0][:type]).to eq(:components)
      end
    end
    it 'specifies the correct target when asked to just run standards' do
      [['--standards'], ['--standard'], ['-s']].each do |a|
        s = Opencontrol::CLI.parse_args(a)
        expect(s[:action]).to eq(:run)
        expect(s[:targets].length).to eq(1)
        expect(s[:targets][0][:type]).to eq(:standards)
      end
    end
    it 'specifies the correct target when asked to run certifications' do
      [['--certifications'], ['--certification'], ['-n']].each do |a|
        s = Opencontrol::CLI.parse_args(a)
        expect(s[:action]).to eq(:run)
        expect(s[:targets].length).to eq(1)
        expect(s[:targets][0][:type]).to eq(:certifications)
      end
    end
    it 'specifies the correct target when asked to run opencontrol files' do
      [['--opencontrols'], ['--opencontrol'], ['-o']].each do |a|
        s = Opencontrol::CLI.parse_args(a)
        expect(s[:action]).to eq(:run)
        expect(s[:targets].length).to eq(1)
        expect(s[:targets][0][:type]).to eq(:opencontrols)
      end
    end
  end

  context 'when parsing command line arguments for custom search' do
    it 'allows a custom target file for components' do
      f = './spec/fixtures/no_issues/components/AU_policy/component.yaml'
      [['--component', f]].each do |a|
        s = Opencontrol::CLI.parse_args(a)
        expect(s[:action]).to eq(:run)
        expect(s[:targets].length).to eq(1)
        expect(s[:targets][0][:type]).to eq(:components)
        expect(s[:targets][0][:pattern]).to eq(f)
      end
    end
    it 'allows a custom target file for standards' do
      f = './spec/fixtures/no_issues/standards/FRIST-800-53.yaml'
      [['--standards', f]].each do |a|
        s = Opencontrol::CLI.parse_args(a)
        expect(s[:action]).to eq(:run)
        expect(s[:targets].length).to eq(1)
        expect(s[:targets][0][:type]).to eq(:standards)
        expect(s[:targets][0][:pattern]).to eq(f)
      end
    end
    it 'allows a custom target file for certifications' do
      f = './spec/fixtures/no_issues/certifications/FredRAMP-low.yaml'
      [['--certifications', f]].each do |a|
        s = Opencontrol::CLI.parse_args(a)
        expect(s[:action]).to eq(:run)
        expect(s[:targets].length).to eq(1)
        expect(s[:targets][0][:type]).to eq(:certifications)
        expect(s[:targets][0][:pattern]).to eq(f)
      end
    end
    it 'allows a custom target file for opencontrols' do
      f = './spec/fixtures/no_issues/opencontrol.yaml'
      [['--opencontrols', f]].each do |a|
        s = Opencontrol::CLI.parse_args(a)
        expect(s[:action]).to eq(:run)
        expect(s[:targets].length).to eq(1)
        expect(s[:targets][0][:type]).to eq(:opencontrols)
        expect(s[:targets][0][:pattern]).to eq(f)
      end
    end
  end
end
