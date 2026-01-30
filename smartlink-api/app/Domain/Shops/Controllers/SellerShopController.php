<?php

namespace App\Domain\Shops\Controllers;

use App\Domain\Shops\Models\Shop;
use App\Domain\Shops\Enums\ShopType;
use App\Domain\Shops\Requests\CreateShopRequest;
use App\Domain\Shops\Requests\SetDefaultWorkflowRequest;
use App\Domain\Shops\Resources\ShopResource;
use App\Domain\Shops\Services\ShopWorkflowService;
use App\Domain\Workflows\Models\Workflow;
use App\Domain\Zones\Models\UserZone;
use Illuminate\Support\Facades\DB;

class SellerShopController
{
    public function __construct(private readonly ShopWorkflowService $shopWorkflowService)
    {
    }

    public function index()
    {
        $seller = request()->user();

        $shops = Shop::query()
            ->where('seller_user_id', $seller->id)
            ->with(['defaultWorkflow'])
            ->latest('id')
            ->paginate(50);

        return ShopResource::collection($shops);
    }

    public function show(Shop $shop)
    {
        $seller = request()->user();
        if ((int) $shop->seller_user_id !== (int) $seller->id) {
            return response()->json(['message' => 'Forbidden.'], 403);
        }

        return new ShopResource($shop->load(['defaultWorkflow']));
    }

    public function store(CreateShopRequest $request)
    {
        $seller = $request->user();
        $data = $request->validated();

        $operationalZoneId = UserZone::query()
            ->where('user_id', $seller->id)
            ->where('type', 'operational')
            ->value('zone_id');

        if (! $operationalZoneId) {
            return response()->json(['message' => 'Operational zone is required for sellers.'], 422);
        }

        if ((int) $operationalZoneId !== (int) $data['zone_id']) {
            return response()->json(['message' => 'Shop zone must match seller operational zone.'], 422);
        }

        $shop = DB::transaction(function () use ($seller, $data) {
            return Shop::create([
                'seller_user_id' => $seller->id,
                'shop_name' => $data['shop_name'],
                'description' => $data['description'] ?? null,
                'zone_id' => $data['zone_id'],
                'address_text' => $data['address_text'],
                'is_verified' => false,
                'verification_phase' => 'phase1',
                'shop_type' => ShopType::tryFrom((string) ($data['shop_type'] ?? 'retail')) ?? ShopType::Retail,
                'default_workflow_id' => Workflow::query()
                    ->where('code', (string) ($data['shop_type'] ?? 'retail'))
                    ->value('id'),
            ]);
        });

        return new ShopResource($shop);
    }

    public function setDefaultWorkflow(SetDefaultWorkflowRequest $request, Shop $shop)
    {
        $seller = $request->user();

        $data = $request->validated();

        /** @var Workflow|null $workflow */
        $workflow = null;
        if (! empty($data['workflow_id'])) {
            $workflow = Workflow::query()->whereKey((int) $data['workflow_id'])->first();
        } elseif (! empty($data['workflow_code'])) {
            $workflow = Workflow::query()->where('code', (string) $data['workflow_code'])->first();
        }

        if (! $workflow) {
            return response()->json(['message' => 'workflow_id or workflow_code is required.'], 422);
        }

        try {
            $updated = $this->shopWorkflowService->setDefaultWorkflow($seller, $shop, $workflow);
        } catch (\RuntimeException $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }

        return new ShopResource($updated->load(['defaultWorkflow']));
    }
}
